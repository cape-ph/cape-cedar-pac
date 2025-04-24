permit(
   principal,
   action == CAPE::Action::"getPipelineExecutors",
   resource is CAPE::APIEndpoint
) when {
   principal.apis.contains(CAPE::API::"api-id-dap") &&
   resource.path == "pipelineexecutors" &&
   resource.method == context.method
};
