import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// @ts-ignore
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")
// @ts-ignore - Admin email bisa di-set via environment variable
const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") || "ikmal.usamah@gmail.com"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders })
  }

  try {
    const {
      guestName,
      guestEmail,
      guestPhone,
      reservationDate,
      reservationTime,
      numberOfGuests,
      tableNumber,
      specialRequests,
      adminEmail, // Optional: override default admin email
    } = await req.json()

    const targetEmail = adminEmail || ADMIN_EMAIL

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #6C3CE3; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center; }
            .content { background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
            .alert-box { background-color: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .guest-info { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #6C3CE3; }
            .reservation-info { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #4CAF50; }
            .action-btn { display: inline-block; padding: 12px 24px; background-color: #6C3CE3; color: white; text-decoration: none; border-radius: 5px; margin-top: 15px; }
            .footer { color: #666; font-size: 12px; margin-top: 20px; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🔔 Reservasi Baru!</h1>
            </div>
            
            <div class="content">
              <div class="alert-box">
                <strong>⚡ Perhatian:</strong> Ada reservasi baru yang memerlukan konfirmasi Anda!
              </div>
              
              <div class="guest-info">
                <h3>👤 Informasi Tamu:</h3>
                <ul>
                  <li><strong>Nama:</strong> ${guestName}</li>
                  <li><strong>Email:</strong> <a href="mailto:${guestEmail}">${guestEmail}</a></li>
                  <li><strong>Telepon:</strong> <a href="tel:${guestPhone}">${guestPhone}</a></li>
                </ul>
              </div>
              
              <div class="reservation-info">
                <h3>📋 Detail Reservasi:</h3>
                <ul>
                  <li><strong>Tanggal:</strong> ${reservationDate}</li>
                  <li><strong>Jam:</strong> ${reservationTime}</li>
                  <li><strong>Jumlah Tamu:</strong> ${numberOfGuests} orang</li>
                  ${tableNumber ? `<li><strong>Nomor Meja:</strong> ${tableNumber}</li>` : ''}
                  ${specialRequests ? `<li><strong>Permintaan Khusus:</strong> ${specialRequests}</li>` : ''}
                </ul>
              </div>
              
              <p style="text-align: center;">
                Silakan buka aplikasi admin untuk mengkonfirmasi atau menolak reservasi ini.
              </p>
              
              <div class="footer">
                <p>Email ini dikirim otomatis dari sistem Reservasi Resto.</p>
                <p>© 2025 Reservasi Resto</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    `

    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Reservasi Resto <noreply@enaknih-resto.me>",
        to: targetEmail,
        subject: `🔔 Reservasi Baru: ${guestName} - ${reservationDate}`,
        html: emailHtml,
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(`Resend API error: ${JSON.stringify(data)}`)
    }

    return new Response(JSON.stringify({ success: true, data }), {
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
