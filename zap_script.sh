#!/bin/bash


API_KEY="1j962r11ihlqkaqu70fba5lnpe"
API_URL="https://snackupitalia.com:5001"
SWAGGER_URL="https://snackupitalia.com:5001/swagger/v1/swagger.json"
JWT_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiI0IiwiZW1haWwiOiJTQGdtYWlsLmNvbSIsInJvbGUiOiJTdHVkZW50IiwibmJmIjoxNzQyODUzMTk4LCJleHAiOjE3NTMzNjUxOTgsImlhdCI6MTc0Mjg1MzE5OCwiaXNzIjoiU25hY2tVcEFQSSIsImF1ZCI6IlNuYWNrVXBDbGllbnRzIn0.6m_dkAGHuvPS_-M08enwG0lMlPHmC1PBW-tLMx8I55s"


echo "Avvio di OWASP ZAP..."
zaproxy -daemon -port 8090 -host 127.0.0.1 -config api.key=$API_KEY



echo "Attesa di 10 secondi per l'avvio..."
sleep 10


echo "[*] Importazione della definizione Swagger..."
curl "http://127.0.0.1:8090/JSON/openapi/action/importUrl/?apikey=$API_KEY&url=$SWAGGER_URL"


CONTEXT_ID=$(curl -s "http://127.0.0.1:8090/JSON/context/action/newContext/?apikey=$API_KEY&contextName=SnackUpContext" | jq -r .contextId)
echo "[*] Context creato con ID: $CONTEXT_ID"


curl "http://127.0.0.1:8090/JSON/context/action/includeInContext/?apikey=$API_KEY&contextName=SnackUpContext&regex=$API_URL.*"


curl "http://127.0.0.1:8090/JSON/httpSessions/action/setSessionToken/?apikey=$API_KEY&sessionToken=Authorization"

curl "http://127.0.0.1:8090/JSON/httpSessions/action/addHttpSessionToken/?apikey=$API_KEY&site=$API_URL&sessionToken=Authorization"

curl "http://127.0.0.1:8090/JSON/httpSessions/action/addSessionTokenValue/?apikey=$API_KEY&site=$API_URL&sessionToken=Authorization&tokenValue=Bearer%20$JWT_TOKEN"

echo "Inizio Spidering"
curl "http://127.0.0.1:8090/JSON/spider/action/scan/?apikey=$API_KEY&url=$API_URL&contextName=SnackUpContext"

sleep 15

echo "Inizio Active Scan"
curl "http://127.0.0.1:8090/JSON/ascan/action/scan/?apikey=$API_KEY&url=$API_URL&contextId=$CONTEXT_ID"


echo "Attesa di 60 secondi per completamento scan..."
sleep 60


echo "Scarico alert trovati"
curl "http://127.0.0.1:8090/JSON/core/view/alerts/?apikey=$API_KEY" | jq

echo "Scansione completata"
