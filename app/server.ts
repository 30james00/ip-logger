import { Application } from './deps.ts';

// get port number from env
const port = Number.parseInt(Deno.env.get("PORT") ?? "80");

// get date on server
const date = new Date().toLocaleString('pl-PL');

// log date name and port (1a)
console.log(`${date}\nMS\nPort: ${port}`);

const app = new Application();

// configure response 
app.use(async (ctx) => {
  // get IP address from request
  const ip = ctx.request.ip;
  const time = await getDate(ip);
  ctx.response.body = `Your IP address: ${ip}\n${time}`;
});

// start server
await app.listen({ port });

/**
 * Get current date in timezone of IP adress
 * @param ip IP adress
 * @returns Formated information about timezone and its date
 */
async function getDate(ip: string): Promise<string> {
  try {
    // ask API for IP data
    const response = await (
      await fetch(`https://ipapi.co/${ip}/json/`)
    ).json();

    // get timezone from response
    let timeZone = response['timezone'];
    // error check
    if(timeZone == undefined) timeZone = "Australia/Adelaide"

    // format date in desired timezone
    const date = new Date().toLocaleString('pl-PL', { timeZone });

    return `Your timezone: ${timeZone}\nDate in your IP's timezone: ${date}`;
  } catch (error) {
    console.log(error);
    return 'error';
  }
}
