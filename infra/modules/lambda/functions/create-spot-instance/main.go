package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	fmt.Println("Evento recebido do CloudWatch:", string(event))

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		return "", fmt.Errorf("erro ao carregar configuração da AWS: %v", err)
	}

	client := sqs.NewFromConfig(cfg)

	queueUrl := "https://sqs.us-east-1.amazonaws.com/722354704330/dev-process-queue.fifo"

	result, err := client.GetQueueAttributes(context.TODO(), &sqs.GetQueueAttributesInput{
		QueueUrl: &queueUrl,
		AttributeNames: []types.QueueAttributeName{
			"ApproximateNumberOfMessages",
		},
	})
	if err != nil {
		return "", fmt.Errorf("erro ao obter atributos da fila: %v", err)
	}

	numMessages, ok := result.Attributes["ApproximateNumberOfMessages"]
	if !ok {
		return "", fmt.Errorf("não foi possível encontrar o número aproximado de mensagens")
	}
	fmt.Printf("Número aproximado de mensagens na fila: %s\n", numMessages)

	return fmt.Sprintf("Evento processado com sucesso. Número aproximado de mensagens na fila: %s", numMessages), nil
}

func main() {
	lambda.Start(HandleRequest)
}
