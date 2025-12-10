// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
// @ts-ignore - Deno imports work at runtime in Supabase Edge Functions
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// @ts-ignore - Deno env works at runtime
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")

// CORS headers untuk mengizinkan request dari browser
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req: Request) => {
  // Handle CORS preflight request
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
      verificationCode,
      reservationDate,
      reservationTime,
    } = await req.json()

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #6C3CE3; color: white; padding: 20px; border-radius: 5px; }
            .code { font-size: 32px; font-weight: bold; color: #6C3CE3; letter-spacing: 5px; text-align: center; padding: 20px; background-color: #f5f5f5; border-radius: 5px; margin: 20px 0; }
            .footer { color: #666; font-size: 12px; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Verifikasi Reservasi Anda</h1>
            </div>
            
            <p>Halo ${guestName},</p>
            <p>Terima kasih atas reservasi Anda! Berikut adalah detail reservasi:</p>
            
            <ul>
              <li><strong>Tanggal:</strong> ${reservationDate}</li>
              <li><strong>Jam:</strong> ${reservationTime}</li>
            </ul>
            
            <p>Gunakan kode verifikasi berikut untuk melihat detail lengkap reservasi Anda:</p>
            
            <div class="code">${verificationCode}</div>
            
            <p>Kode ini hanya berlaku untuk Anda dan jangan dibagikan kepada orang lain.</p>
            
            <div class="footer">
              <p>Jika Anda tidak melakukan reservasi ini, abaikan email ini.</p>
            </div>
          </div>
        </body>
      </html>
    `

    // Send email using Resend API directly with fetch
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "onboarding@resend.dev", // Use this for testing, or your verified domain
        to: guestEmail,
        subject: "Kode Verifikasi Reservasi Anda",
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

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/send_verification_email' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
