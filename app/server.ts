const port = 8080;

const date = new Date().toLocaleString('pl-PL');

const server = Deno.listen({ port });

// log date name and port (1a)
console.log(`${date}\nMS\nPort: ${port}`);

// handle connection
for await (const conn of server) {
  (async () => {
    // create HTTP connection
    const httpConn = Deno.serveHttp(conn);
    // handle request
    for await (const requestEvent of httpConn) {
      // get ip from request header
      const ip =
        requestEvent.request.headers.get('host')?.split(':')[0] ?? 'unknown';
      // check ip
      if (ip != 'unknown') {
        // create response body
        const body = `${ip}\n`;
        requestEvent.respondWith(
          new Response(body, {
            status: 200,
          })
        );
      }
      // handle error
      requestEvent.respondWith(new Response('IP not found', { status: 400 }));
    }
  })();
}

async function getTime(url: string): Promise<string> {
  try {
    // ask API for IP data
    const response = await (
      await fetch(`https://ipapi.co/${url}/json/`)
    ).json();

    // get timezone from response
    const timeZone = response['timezone'];

    // format date in desired timezone
    const date = new Date().toLocaleString('pl-PL', { timeZone });

    return `Your timezone: ${timeZone}\nDate in your IP's timezone: ${date}`;
  } catch (error) {
    console.log(error);
    return "error";
  }
}
