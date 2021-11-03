import { Application } from 'https://deno.land/x/oak/mod.ts';
const port = 8080;

const date = new Date().toLocaleString('pl-PL');

// log date name and port (1a)
console.log(`${date}\nMS\nPort: ${port}`);

const app = new Application();

app.use(async (ctx) => {
  const ip = ctx.request.ip;
  const time = await getTime(ip);
  ctx.response.body = `Your IP address: ${ip}\n${time}`;
});

await app.listen({ port });

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
    return 'error';
  }
}
