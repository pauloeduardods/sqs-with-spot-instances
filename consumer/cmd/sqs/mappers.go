package sqs

import (
	"consumer/internal/process"
	"consumer/pkg/Logger"
	"context"

	sqsTypes "github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

type Mapper struct {
	process *process.Process
	logger  *Logger.Logger
}

func NewMapper(logger *Logger.Logger) *Mapper {
	return &Mapper{
		process: process.NewProcess(logger),
		logger:  logger,
	}
}

func (m *Mapper) HandleProcess(ctx context.Context, message sqsTypes.Message) error {
	return m.process.Handler(ctx, *message.Body)
}
