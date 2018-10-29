presets:
- labels:
    preset-compute-service-account: "true" # Service account with "Compute Admin" and "Compute OS Admin Login" roles
  env:
    - name: GOOGLE_APPLICATION_CREDENTIALS
      value: /etc/service-account/compute-service-account.json
  volumes:
  - name: compute-service-account
    secret:
      secretName: compute-service-account
  volumeMounts:
  - name: compute-service-account
    mountPath: /etc/service-account
    readOnly: true

presubmits: # runs on PRs
  {{ .OrganizationOrUser }}/kyma:
  - name: prow/components/ui-api-layer
    run_if_changed: "components/ui-api-layer"
    context: prow/components/ui-api-layer
    skip_report: false # from documentation: SkipReport skips commenting and setting status on GitHub.
    spec:
      containers:
      - image: alpine
        command: ["/bin/printenv"]
  - name: kyma-integration
    trigger: "(?m)^/test kyma-integration"
    rerun_command: "/test kyma-integration"
    context: kyma-integration
    skip_report: false # from documentation: SkipReport skips commenting and setting status on GitHub.
    max_concurrency: 10
    labels:
      preset-compute-service-account: "true"
    spec:
      containers:
      - image: eu.gcr.io/kyma-project/snapshot/test/integration:0.0.1 # created by running `docker build -t <image> .` in the integration-job directory.

plank:
  allow_cancellations: true # AllowCancellations enables aborting presubmit jobs for commits that have been superseded by newer commits in Github pull requests.
