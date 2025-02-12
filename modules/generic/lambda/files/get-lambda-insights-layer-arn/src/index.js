const axios = require('axios');
const cheerio = require('cheerio');

const urls = {
  arm64: 'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versionsARM.html',
  x86_64: 'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versionsx86-64.html'
};

const fetchAndParse = async (url) => {
  try {
    const response = await axios.get(url);
    const htmlContent = response.data;
    const $ = cheerio.load(htmlContent);
    const insightsArns = {};

    $('h2[id^="Lambda-Insights-extension"]').each((i, elem) => {
      const versionId = $(elem).attr('id');
      const versionNumber = versionId.split('-').pop();
      insightsArns[versionNumber] = {};

      const table = $(elem).nextAll('div.table-container').first().find('table');
      const rows = table.find('tr').slice(1);

      rows.each((j, row) => {
        const columns = $(row).find('td');
        const arn = $(columns[1]).text().trim();
        const region = arn.split(':')[3];
        insightsArns[versionNumber][region] = arn;
      });
    });

    return insightsArns;
  } catch (error) {
    throw new Error('Error fetching the page: ', error);
  }
};

const getLayerArn = async (arch, region, version = null) => {
  const url = urls[arch];
  const data = await fetchAndParse(url);
  const v = version || Object.keys(data).find(v => data[v][region]);

  if (!data[v]) {
    throw new Error(`Invalid version: ${v} for arch: ${arch}`);
    return;
  }

  if (!data[v][region]) {
    throw new Error(`Invalid region: ${region} for arch/version: ${arch}/${v}`);
    return;
  }

  return data[v][region];
};

const main = async () => {
  const args = process.argv.slice(2);
  const arch = args[0];
  const region = args[1];
  const version = args[2];

  if (!arch || !region) {
    throw new Error('Usage: node index.js <arch> <region> [version]');
  }

  if (!(arch in urls)) {
    throw new Error(`Invalid arch: ${arch}`);
  }

  const layerArn = await getLayerArn(arch, region, version);
  console.log(JSON.stringify({layerArn}));
}

try {
  main();
} catch (error) {
  console.error(message);
  process.exit(1);
};
