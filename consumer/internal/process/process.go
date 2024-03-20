package process

import (
	"consumer/pkg/Logger"
	"context"
	"math/rand"
	"time"
)

type Process struct {
	logger *Logger.Logger
}

func NewProcess(logger *Logger.Logger) *Process {
	return &Process{
		logger: logger,
	}
}

func (p *Process) Handler(ctx context.Context, message string) error {
	rand.NewSource(time.Now().UnixNano())

	sleepDuration := rand.Intn(4) + 2 // 2 - 5 min

	sleepTime := time.Duration(sleepDuration) * time.Minute

	time.Sleep(sleepTime)

	p.logger.Info("Message processed: %s, sleep time: %d", message, sleepDuration)

	return nil
}
