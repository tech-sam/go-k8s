package handlers

import (
	"net/http"
	"os"

	"github.com/dimfeld/httptreemux/v5"
	"github.com/tech-sam/go-k8s/app/services/sales-api/handlers/v1/testgrp"
	"go.uber.org/zap"
)

// APIMuxConfig contains all the mandatory systems required by handlers.
type APIMuxConfig struct {
	Shutdown chan os.Signal
	Log      *zap.SugaredLogger
}

// APIMux constructs a http.Handler with all application routes defined.
func APIMux(cfg APIMuxConfig) http.Handler {
	mux := httptreemux.NewContextMux()

	mux.Handle(http.MethodGet, "/test", testgrp.Test)
	return mux
}
