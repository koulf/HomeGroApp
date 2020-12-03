#include <ESP8266WiFi.h>
#include <DHT.h>



const char *ssid = "nombre de la red";
const char *password = "contraseña";

const char *host = "things.ubidots.com";

/* Definiendo el modelo de sensor y el pin al que estará conectado */
#define DHTTYPE DHT11
#define DHTPIN 2
DHT dht(DHTPIN, DHTTYPE, 11);

/* Variables to sense and pin define**/
float temperature;
float humidity;
const char *deviceToken = "BBFF-mI07ByVJpWXrdFdJCX6dH7RUVqjK2p";

int pinDHT11 = 2;
int water_pump_pin = 3;
int water_pump_speed = 255;
bool irrigation = false;

void setup()
{
	Serial.begin(115200);
	Serial.println();

	dht.begin();

	Serial.printf("Connecting to %s ", ssid);
	WiFi.mode(WIFI_STA);
	WiFi.begin(ssid, password);
	while (WiFi.status() != WL_CONNECTED)
	{
		delay(500);
		Serial.print(".");
	}
	Serial.println(" connected");
}

void loop()
{
	WiFiClient client;
	temperature = dht.readTemperature();
	humidity = dht.readHumidity();

	if(humidity < 5)
	{
		digitalWrite(water_pump_pin, HIGH);
		Serial.println("Irrigación");
		analogWrite(water_pump_pin, water_pump_speed);
		irrigation = true;
	}
	else
	{
		digitalWrite(water_pump_pin, LOW);
		Serial.println("Riego detenido");
	}



	Serial.printf("\nConnecting to %s ... ", host);
	if (client.connect(host, 80))
	{
		Serial.println("Connected!!!");
		String data;

		if(irrigation) {
			// Petición para registrar riego
			data = "irrigation=1";
			Serial.println("Requesting POST health...");
			client.println("POST /api/v1.6/devices/x HTTP/1.1");
			client.println("Host: things.ubidots.com");
			client.println("Content-Type: application/x-www-form-urlencoded");
			client.print("Content-Length: ");
			client.println(data.length());
			client.println("X-Auth-Token: " + deviceToken);
			client.println();
			client.print(data);
			irrigation = false;
		}

		// Petición para registrar temperatura
		data = "temperature=" + String(temperature);
		Serial.println("Requesting POST temperature...");
		client.println("POST /api/v1.6/devices/x HTTP/1.1");
		client.println("Host: things.ubidots.com");
		client.println("Content-Type: application/x-www-form-urlencoded");
		client.print("Content-Length: ");
		client.println(data.length());
		client.println("X-Auth-Token: " + deviceToken);
		client.println();
		client.print(data);

		// Petición para registrar humedad
		data = "humidity=" + String(humidity);
		Serial.println("Requesting POST humidity...");
		client.println("POST /api/v1.6/devices/x HTTP/1.1");
		client.println("Host: things.ubidots.com");
		client.println("Content-Type: application/x-www-form-urlencoded");
		client.print("Content-Length: ");
		client.println(data.length());
		client.println("X-Auth-Token: " + deviceToken);
		client.println();
		client.print(data);


		// Código utilizado para debugeo
		Serial.println("Response:");
		while (client.connected())
			if (client.available())
			{
				String line = client.readStringUntil('\n');
				Serial.println(line);
			}

		if (client.connected())
			client.stop();
		Serial.println();
		Serial.println("closing connection");
	}
	else
	{
		Serial.println("connection failed!]");
		client.stop();
	}
	delay(2000);
}
