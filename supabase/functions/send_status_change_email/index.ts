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
      newStatus,
      previousStatus,
      reservationDate,
      reservationTime,
      tableNumber,
    } = await req.json()

    // Status colors and icons
    const statusInfo: Record<string, { color: string; icon: string; message: string }> = {
      'Terkonfirmasi': { 
        color: '#4CAF50', 
        icon: '✅', 
        message: 'Reservasi Anda telah dikonfirmasi! Kami menantikan kedatangan Anda.' 
      },
      'Selesai': { 
        color: '#2196F3', 
        icon: '🎉', 
        message: 'Terima kasih telah berkunjung! Kami berharap Anda menikmati pengalaman di restoran kami.' 
      },
      'Dibatalkan': { 
        color: '#F44336', 
        icon: '❌', 
        message: 'Reservasi Anda telah dibatalkan. Jika ini kesalahan, silakan hubungi kami.' 
      },
      'Tertunda': { 
        color: '#FFA500', 
        icon: '⏳', 
        message: 'Reservasi Anda sedang menunggu konfirmasi dari admin.' 
      },
    }

    const info = statusInfo[newStatus] || { color: '#666', icon: '📋', message: '' }

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: ${info.color}; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center; }
            .content { background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
            .status-badge { display: inline-block; padding: 10px 20px; background-color: ${info.color}; color: white; border-radius: 20px; font-weight: bold; margin: 10px 0; }
            .details { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .footer { color: #666; font-size: 12px; margin-top: 20px; text-align: center; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>${info.icon} Status Reservasi Diperbarui</h1>
            </div>
            
            <div class="content">
              <p>Halo <strong>${guestName}</strong>,</p>
              
              <p>Status reservasi Anda telah berubah:</p>
              
              <p style="text-align: center;">
                <span style="color: #999; text-decoration: line-through;">${previousStatus}</span>
                &nbsp;→&nbsp;
                <span class="status-badge">${newStatus}</span>
              </p>
              
              <p>${info.message}</p>
              
              <div class="details">
                <h3>📋 Detail Reservasi:</h3>
                <ul>
                  <li><strong>Tanggal:</strong> ${reservationDate}</li>
                  <li><strong>Jam:</strong> ${reservationTime}</li>
                  ${tableNumber ? `<li><strong>Nomor Meja:</strong> ${tableNumber}</li>` : ''}
                </ul>
              </div>
              
              <div class="footer">
                <p>Jika ada pertanyaan, silakan hubungi kami.</p>
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
        subject: `${info.icon} Status Reservasi: ${newStatus}`,
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
