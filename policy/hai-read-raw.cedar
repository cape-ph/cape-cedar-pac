permit(
   principal,
   action == CAPE::Action::"readRaw",
   resource is CAPE::ObjectStorage
) when {
   principal.tributaries.contains("hai") && resource.name == "haiRaw"
};
