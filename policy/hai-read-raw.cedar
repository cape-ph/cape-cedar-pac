permit(
   principal,
   action == CAPE::Action::"readRaw",
   resource is CAPE::Bucket
) when {
   principal.tributaries.contains("hai") && resource.name == "haiRaw"
};
