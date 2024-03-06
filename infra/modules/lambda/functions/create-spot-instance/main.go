package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	fmt.Println("Evento recebido do CloudWatch:", string(event))
	return "Evento processado com sucesso", nil
}

func main() {
	lambda.Start(HandleRequest)
}
