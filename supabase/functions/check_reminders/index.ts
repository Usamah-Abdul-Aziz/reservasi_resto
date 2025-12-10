import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// @ts-ignore
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")
// @ts-ignore
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")
// @ts-ignore
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_KEY!)
    
    // Get current time and 3 hours from now
    const now = new Date()
    const threeHoursLater = new Date(now.getTime() + 3 * 60 * 60 * 1000)
    
    // Get today's date in YYYY-MM-DD format
    const today = now.toISOString().split('T')[0]
    
    // Get confirmed reservations for today
    const { data: reservations, error } = await supabase
      .from('reservations')
      .select('*')
      .eq('status', 1) // confirmed
      .gte('reservationDate', today)
      .lte('reservationDate', today + 'T23:59:59')
    
    if (error) {
      throw new Error(`Database error: ${error.message}`)
    }
    
    const remindersToSend: any[] = []
    const notificationsToCreate: any[] = []
    
    for (const reservation of reservations || []) {
      // Parse reservation time
      const [hours, minutes] = reservation.reservationTime.split(':').map(Number)
      const reservationDateTime = new Date(reservation.reservationDate)
      reservationDateTime.setHours(hours, minutes, 0, 0)
      
      // Check if reservation is within 3 hours
      const timeDiff = reservationDateTime.getTime() - now.getTime()
      const hoursUntil = timeDiff / (1000 * 60 * 60)
      
      if (hoursUntil > 0 && hoursUntil <= 3) {
        // Check if reminder already sent today
        const { data: existingReminder } = await supabase
          .from('admin_notifications')
          .select('id')
          .eq('reservationId', reservation.id)
          .eq('type', 2) // reminder type
          .gte('createdAt', today)
          .single()
        
        if (!existingReminder) {
          remindersToSend.push(reservation)
          
          // Create admin notification
          notificationsToCreate.push({
            id: crypto.randomUUID(),
            title: '⏰ Reminder Reservasi',
            message: `${reservation.guestName} akan datang dalam ${Math.round(hoursUntil)} jam!\nJam ${reservation.reservationTime}`,
            type: 2, // reminder
            reservationId: reservation.id,
            createdAt: new Date().toISOString(),
            isRead: false,
          })
        }
      }
    }
    
    // Insert admin notifications
    if (notificationsToCreate.length > 0) {
      await supabase.from('admin_notifications').insert(notificationsToCreate)
    }
    
    // Send reminder emails
    const emailResults = []
    for (const reservation of remindersToSend) {
      const emailHtml = `
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background-color: #FF9800; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center; }
              .content { background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
              .reminder-box { background-color: #fff3e0; border: 2px solid #FF9800; padding: 20px; border-radius: 10px; margin: 15px 0; text-align: center; }
              .time-left { font-size: 28px; font-weight: bold; color: #FF9800; }
              .code { font-size: 24px; font-weight: bold; color: #6C3CE3; letter-spacing: 3px; text-align: center; padding: 15px; background-color: #f0f0f0; border-radius: 5px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>⏰ Pengingat Reservasi</h1>
              </div>
              <div class="content">
                <p>Halo <strong>${reservation.guestName}</strong>,</p>
                <div class="reminder-box">
                  <p>Reservasi Anda akan dimulai dalam:</p>
                  <p class="time-left">⏰ KURANG DARI 3 JAM!</p>
                </div>
                <p><strong>Waktu:</strong> ${reservation.reservationTime}</p>
                <p><strong>Jumlah Tamu:</strong> ${reservation.numberOfGuests} orang</p>
                <p>Kode verifikasi Anda:</p>
                <div class="code">${reservation.verificationCode}</div>
                <p style="text-align: center; margin-top: 20px;">Kami menantikan kedatangan Anda! 🎉</p>
              </div>
            </div>
          </body>
        </html>
      `
      
      try {
        const response = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: "Reservasi Resto <noreply@enaknih-resto.me>",
            to: reservation.guestEmail,
            subject: "⏰ Pengingat: Reservasi Anda Kurang dari 3 Jam Lagi!",
            html: emailHtml,
          }),
        })
        
        const data = await response.json()
        emailResults.push({ email: reservation.guestEmail, success: response.ok, data })
      } catch (e) {
        emailResults.push({ email: reservation.guestEmail, success: false, error: e })
      }
    }
    
    return new Response(JSON.stringify({
      success: true,
      remindersProcessed: remindersToSend.length,
      notificationsCreated: notificationsToCreate.length,
      emailResults,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error: unknown) {
    console.error("Error:", error)
    const errorMessage = error instanceof Error ? error.message : "Unknown error"
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
    )
  }
})
