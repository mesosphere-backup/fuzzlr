package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"time"

	"github.com/mesosphere/fuzzlr/scheduler"
)

func main() {
	fs := flag.NewFlagSet("fuzzlr", flag.ExitOnError)
	master := fs.String("master", "localhost:5050", "Location of leading Mesos master")
	shutdownTimeout := fs.Duration("shutdown.timeout", 10*time.Second, "Shutdown timeout")

	fs.Parse(os.Args[1:])

	sched := scheduler.New()
	driver, err := scheduler.NewDriver(*master, sched)
	if err != nil {
		log.Printf("Unable to create scheduler driver: %s", err)
		return
	}

	go func() {
		sigch := make(chan os.Signal, 1)
		signal.Notify(sigch, os.Interrupt, os.Kill)
		if s := <-sigch; s != os.Interrupt {
			return
		}
		log.Println("Fuzzlr is shutting down")
		if err := sched.Shutdown(*shutdownTimeout); err != nil {
			log.Print(err)
		}
		driver.Stop(false)
	}()

	if status, err := driver.Run(); err != nil {
		log.Printf("Framework stopped with status %s and error: %s", status, err)
	}

	log.Println("Exiting...")
}
