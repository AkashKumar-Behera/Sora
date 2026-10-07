const domain = "https://music.youtube.com/";
const String baseUrl = '${domain}youtubei/v1/';
// Public YouTube Innertube web client key (non-sensitive client identifier)
const String _defaultKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30";

const String _ytApiKey = String.fromEnvironment(
  'YOUTUBE_API_KEY',
  defaultValue: _defaultKey,
);

const fixedParms =
    '?prettyPrint=false&alt=json&key=$_ytApiKey';
const userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36';
