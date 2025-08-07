using System.Security.Cryptography;
using System.Text;

class Program
{
	const string credsFile = ".remoteit/credentials";
	class KeyAndSecret
	{
		public bool HasError;
		public string Error;
		public string Key;
		public string Secret;
	}

	private static async Task Main()
	{
		KeyAndSecret keyAndSecret = readKeyAndSecret();
		if (keyAndSecret.HasError)
		{
			Console.WriteLine(keyAndSecret.Error);
			return;
		}

		string host = "api.remote.it";
		string urlPath = "/graphql/v1";  // Ensure proper formatting with a trailing slash
		string url = $"https://{host}{urlPath}";
		string verb = "POST";
		string contentType = "application/json";
		string date = DateTime.UtcNow.ToString("r"); // RFC 1123 format

		string data = "{ \"query\": \"{ login { email  devices (size: 1000, from: 0) { items { id name services { id name} } } } }\" }";
		// string data = "{\"query\":\"{ applicationTypes { id name description port proxy protocol } }\"}";

		// line to sign
		string lineToSign = $"(request-target): {verb.ToLower()} {urlPath}\n"
			+ $"host: {host}\n"
			+ $"date: {date}\n"
			+ $"content-type: {contentType}\n"
			+ $"content-length: {data.Length}";

		byte[] signedLine = generateSignature(lineToSign, keyAndSecret.Secret);
		string signedLineAsBase64 = Convert.ToBase64String(signedLine);

		// signature line
		string signatureLine = $"keyId=\"{keyAndSecret.Key}\""
			+ $",algorithm=\"hmac-sha256\""
			+ $",headers=\"(request-target) host date content-type content-length\""
			+ $",signature=\"{signedLineAsBase64}\"";

		// create HTTP request
		var content = new StringContent(data, Encoding.UTF8, contentType);
		content.Headers.Remove("Content-Type");
		content.Headers.Remove("Content-Length");
		content.Headers.Add("Content-Type", contentType);
		content.Headers.Add("Content-Length", data.Length.ToString());

		HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, url);
		request.Headers.Add("User-Agent", "sample-sdk-c#");

		request.Headers.Add("Date", date);
		request.Headers.Add("Authorization", "Signature " + signatureLine);
		request.Content = content;

		// execute + read response
		var client = new HttpClient();
		HttpResponseMessage response = await client.SendAsync(request);
		string responseBody = await response.Content.ReadAsStringAsync();

		Console.WriteLine("\nResponse: {0}", response.ToString());
		Console.WriteLine("\nResponse Body: {0}", responseBody);
	}

	private static byte[] generateSignature(string lineToSign, string secret)
	{
		byte[] secretAsBytes = Convert.FromBase64String(secret);
		using (var hmac = new HMACSHA256(secretAsBytes))
		{
			byte[] lineToSignAsBytes = Encoding.UTF8.GetBytes(lineToSign);
			return hmac.ComputeHash(lineToSignAsBytes);
		}
	}

	private static KeyAndSecret readKeyAndSecret()
	{
		//Reads the credentials from the credentials file. If there is more than one, it will take the last; or you can read from environment variables instead.
		string homeFolder = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
		string credentialsPath = Path.Combine(homeFolder, credsFile);
		if (!File.Exists(credentialsPath))
		{
			return new KeyAndSecret { HasError = true, Error = "err: credentials file not found" };
		}

		var credentials = File.ReadAllLines(credentialsPath);
		string accessKeyId = "";
		string secretAccessKey = "";
		//assumes that there is one profile. If you have more than one, adapt this part as needed. 	
		bool accessKeyFound = false;
		bool secretKeyFound = false;	

		foreach (var line in credentials)
		{
			if (line.StartsWith("R3_ACCESS_KEY_ID="))
			{
				accessKeyId = line.Split(new char[] { '=' }, 2)[1];
				accessKeyFound = true;
			}
			else if (line.StartsWith("R3_SECRET_ACCESS_KEY="))
			{
				secretAccessKey = line.Split(new char[] { '=' }, 2)[1];
				secretKeyFound = true;
			}
	
			if (accessKeyFound && secretKeyFound)
				break;
		}

		if (string.IsNullOrEmpty(accessKeyId) || string.IsNullOrEmpty(secretAccessKey))
		{
			return new KeyAndSecret { HasError = true, Error = "err: missing API credentials in the credentials file" };
		}

		return new KeyAndSecret { Key = accessKeyId, Secret = secretAccessKey };
	}
}
