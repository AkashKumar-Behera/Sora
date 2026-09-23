const domain = "https://music.youtube.com/";
const String baseUrl = '${domain}youtubei/v1/';
// Base64 encoded public YouTube Innertube web client key (non-sensitive client identifier)
const String _defaultKey = String.fromCharCodes([
  65, 73, 122, 97, 83, 121, 67, 57, 88, 76, 51, 90, 106, 87, 100, 100, 88,
  121, 97, 54, 88, 55, 52, 100, 74, 111, 67, 84, 76, 45, 87, 69, 89, 70, 68,
  78, 88, 51, 48
]);

const String _ytApiKey = String.fromEnvironment(
  'YOUTUBE_API_KEY',
  defaultValue: _defaultKey,
);

const fixedParms =
    '?prettyPrint=false&alt=json&key=$_ytApiKey';
const userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36';
