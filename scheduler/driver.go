package scheduler

import (
	"errors"

	"github.com/gogo/protobuf/proto"
	pb "github.com/mesos/mesos-go/mesosproto"
	sched "github.com/mesos/mesos-go/scheduler"
)

func NewDriver(master string, s sched.Scheduler) (sched.SchedulerDriver, error) {
	if master == "" {
		return nil, errors.New("driver: empty master")
	}
	return sched.NewMesosSchedulerDriver(sched.DriverConfig{
		Master: master,
		Framework: &pb.FrameworkInfo{
			Name:            proto.String("Fuzzlr"),
			Checkpoint:      proto.Bool(true),
			FailoverTimeout: proto.Float64(60 * 60 * 24 * 7),
			// User: proto.String(""),
		},
		Scheduler: s,
	})
}
