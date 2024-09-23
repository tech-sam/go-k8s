package testgrp

import (
	"context"
	"net/http"

	"github.com/tech-sam/go-k8s/foundation/web"
)

func Test(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	status := struct {
		Status string
	}{
		Status: "OK",
	}
	return web.Respond(ctx, w, status, http.StatusOK)
}
