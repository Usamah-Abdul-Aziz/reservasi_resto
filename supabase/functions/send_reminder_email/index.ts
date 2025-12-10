import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// @ts-ignore
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")

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
      guestEmail,
      guestName,
      reservationDate,
      reservationTime,
      numberOfGuests,
      tableNumber,
      verificationCode,
    } = await req.json()

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #FF9800; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center; }
            .content { background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
            .reminder-box { background-color: #fff3e0; border: 2px solid #FF9800; padding: 20px; border-radius: 10px; margin: 15px 0; text-align: center; }
            .time-left { font-size: 28px; font-weight: bold; color: #FF9800; }
            .details { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .code { font-size: 24px; font-weight: bold; color: #6C3CE3; letter-spacing: 3px; text-align: center; padding: 15px; background-color: #f0f0f0; border-radius: 5px; margin: 15px 0; }
            .checklist { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .checklist li { margin: 8px 0; }
            .footer { color: #666; font-size: 12px; margin-top: 20px; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>⏰ Pengingat Reservasi</h1>
            </div>
            
            <div class="content">
              <p>Halo <strong>${guestName}</strong>,</p>
              
              <div class="reminder-box">
                <p>Reservasi Anda akan dimulai dalam:</p>
                <p class="time-left">⏰ 3 JAM LAGI!</p>
              </div>
              
              <div class="details">
                <h3>📋 Detail Reservasi:</h3>
                <ul>
                  <li><strong>Tanggal:</strong> ${reservationDate}</li>
                  <li><strong>Jam:</strong> ${reservationTime}</li>
                  <li><strong>Jumlah Tamu:</strong> ${numberOfGuests} orang</li>
                  ${tableNumber ? `<li><strong>Nomor Meja:</strong> ${tableNumber}</li>` : ''}
                </ul>
              </div>
              
              <p>Kode verifikasi Anda:</p>
              <div class="code">${verificationCode}</div>
              
              <div class="checklist">
                <h3>✅ Checklist sebelum datang:</h3>
                <ul>
                  <li>📱 Siapkan kode verifikasi di atas</li>
                  <li>⏰ Datang tepat waktu atau 10 menit lebih awal</li>
                  <li>📞 Hubungi kami jika ada perubahan</li>
                </ul>
              </div>
              
              <p style="text-align: center; color: #666;">
                Kami menantikan kedatangan Anda! 🎉
              </p>
              
              <div class="footer">
                <p>Jika Anda perlu membatalkan, silakan hubungi kami segera.</p>
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
        to: guestEmail,
        subject: `⏰ Pengingat: Reservasi Anda 3 Jam Lagi!`,
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
