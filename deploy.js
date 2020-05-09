const fs = require('fs-extra');
async function main() {
  let html = await fs.readFile('dist/index.html', 'utf8');
  html = html.replace('base href="/"', 'base href="/farm/"')
  await fs.writeFile('dist/index.html', html, 'utf8');
  console.log('done');
}
main();