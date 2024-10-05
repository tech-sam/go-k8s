package testgrp

import (
	"context"
	"math/rand"
	"net/http"

	"github.com/tech-sam/go-k8s/foundation/web"
)

func Test(ctx context.Context, w http.ResponseWriter, r *http.Request) error {

	if n := rand.Intn(100); n%2 == 0 {
		//return v1.NewRequestError(errors.New("TRUSTED ERROR"), http.StatusBadRequest)
		panic("OHH NOO PANIC")
	}
	status := struct {
		Status string
	}{
		Status: "OK",
	}
	return web.Respond(ctx, w, status, http.StatusOK)
}
