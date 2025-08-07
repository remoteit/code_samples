var client = new HttpClient();
string accessKeyId = "LDQJKWVZWPYK3UNHFNBG";
string secretAccessKey = "WUoajxE8YiFq62dozRXEgaYpSonIzal1fal18Q06";

// Format Date in GMT (RFC 1123 format)
string date = DateTime.UtcNow.ToString("r");
int datime= DateTime.UtcNow.Ticks
string host = "api.remote.it";
string urlPath = "graphql/v1";
string url = $"https://{host}/{urlPath}";
string verb = "POST";
string contentType = "application/json";
 // Signing String
string signingString = $"(request-target): {verb.ToLower()} /{urlPath}\n" +
                        $"host: {host}\n" +
                        $"date: {date}\n" +
                        $"content-type: {contentType}";

var request = new HttpRequestMessage
{
    Method = HttpMethod.Post,
    RequestUri = new Uri("https://api.remote.it/graphql/v1"),
    Headers = {
        { "Host", "api.remote.it" },
        { "Date", date },
        { "Signature", signingString },
        { "Signature-Input", "remoteit=("@method" "@authority" "@target-uri" "date");keyid="@accessKeyId";alg="hmac-sha256";created="@datime";expires="@datime" },
        { "Authorization", "" },
    },
    Content = new StringContent("{\"query\":\"#Gets the list of devices limited to the first 1000\\n#hasMore - if there are more devices in the account than requested\\n#total - total number of devices based on query filter and account\\n#Retrieves details of each devices such as\\n#id, online/offline state, lastReported Date\\n#which users have accounts\\n#tags and attributes associated with each device\\n\\nquery {\\n\\tlogin {\\n\\t\\t\\n\\t\\tid\\n\\t\\temail\\n\\t\\tcreated\\n\\t\\tlastLogin\\n\\t\\torganization {\\n\\t\\t\\tname\\n\\t\\t\\tid\\n\\t\\t\\tmembers {\\n\\t\\t\\t\\tuser {\\n\\t\\t\\t\\t\\temail\\n\\t\\t\\t\\t}\\n\\t\\t\\t}\\n\\t\\t}\\n\\t\\taccessKeys {\\n\\t\\t\\tlastUsed\\n\\t\\t\\tkey\\n\\t\\t}\\n\\t\\tlicenses {\\n\\t\\t\\tcreated\\n\\t\\t\\tid\\n\\t\\t\\tplan {\\n\\t\\t\\t\\tname\\n\\t\\t\\t}\\n\\t\\t\\tquantity\\n\\t\\t\\texpiration\\n\\t\\t}\\n\\t\\tdevices(from: 0) {\\n\\t\\t\\thasMore\\n\\t\\t\\ttotal\\n\\t\\t\\tlast\\n\\t\\t\\titems {\\n\\t\\t\\t\\tid\\n\\t\\t\\t\\tname\\n\\t\\t\\t\\tstate\\n\\t\\t\\t\\towner {\\n\\t\\t\\t\\t\\temail\\n\\t\\t\\t\\t}\\n\\t\\t\\t\\teventsUrl\\n\\t\\t\\t\\t\\n\\t\\t\\t\\tversion\\n\\t\\t\\t\\tcreated\\n\\t\\t\\t\\tlicense\\n\\t\\t\\t\\tmanufacturer\\n\\t\\t\\t\\tplatform\\n\\t\\t\\t\\tlastReported\\n\\t\\t\\t\\tconfigurable\\n\\t\\t\\t\\tendpoint {\\n\\t\\t\\t\\t\\texternalAddress\\n\\t\\t\\t\\t\\tgeo {\\n\\t\\t\\t\\t\\t\\tisp\\n\\t\\t\\t\\t\\t\\tconnectionType\\n\\t\\t\\t\\t\\t\\t\\n\\t\\t\\t\\t\\t\\tcountryName\\n\\t\\t\\t\\t\\t\\tcity\\n\\t\\t\\t\\t\\t\\t\\n\\t\\t\\t\\t\\t}\\n\\t\\t\\t\\t}\\n\\t\\t\\t\\tservices {\\n\\t\\t\\t\\t\\tid\\n\\t\\t\\t\\t\\tcreated\\n\\t\\t\\t\\t\\thost\\n\\t\\t\\t\\t\\tport\\n\\t\\t\\t\\t\\ttype\\n\\t\\t\\t\\t\\tname\\n\\t\\t\\t\\t\\tstate\\n\\t\\t\\t\\t\\taccess {\\n\\t\\t\\t\\t\\t\\tuser {\\n\\t\\t\\t\\t\\t\\t\\temail\\n\\t\\t\\t\\t\\t\\t}\\n\\t\\t\\t\\t\\t}\\n\\t\\t\\t\\t\\tenabled\\n\\t\\t\\t\\t\\tlink {\\n\\t\\t\\t\\t\\t\\tenabled\\n\\t\\t\\t\\t\\t\\turl\\n\\t\\t\\t\\t\\t\\tpassword\\n\\t\\t\\t\\t\\t\\tcreated\\n\\t\\t\\t\\t\\t}\\n\\t\\t\\t\\t}\\n\\t\\t\\t}\\t\\n\\t\\t}\\n\\t}\\n}\\n\\n\"}")
    {
        Headers =
        {
            ContentType = new MediaTypeHeaderValue("application/graphql")
        }
    }
};
using (var response = await client.SendAsync(request))
{
    response.EnsureSuccessStatusCode();
    var body = await response.Content.ReadAsStringAsync();
    Console.WriteLine(body);
}