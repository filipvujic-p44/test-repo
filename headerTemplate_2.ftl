<#compress>
    <#assign p44 = interactionRecords[0].requestBody>
    {
    "Content-Type": "application/json",
    "Authorization":"Bearer ${p44.vendorAuthentication.credential2!}"
    }
</#compress>