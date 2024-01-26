<#compress>
    <#assign p44 = interactionRecords[0].requestBody>
    <#function has_content node>
	<#return node?? && node?has_content && node?trim?has_content && node!=null>
	</#function>
      <#attempt >
        <#assign cp1 = interactionRecords[0].vendorResponseBody>
        <#recover >
            <#assign cp1 = "">
    </#attempt>
    <#assign weightSum = 0>
    <#list p44.lineItems as item>
        <#assign weightSum += item.totalWeight!0>
    </#list>
</#compress>
{
    "shipment_type": "DRY",
    "origin_zip": "${p44.originAddress.postalCode!}",
    "dest_zip": "${p44.destinationAddress.postalCode!}",
    "weight": ${weightSum},
    <#if (p44.totalLinearFeet?has_content && p44.totalLinearFeet > 0)>
        
        "linear_feet": ${p44.totalLinearFeet!},
        
    <#elseif (cp1?has_content && cp1.MLP_GET_LNR_FT?has_content && cp1.MLP_GET_LNR_FT[0].TOTAL_LINEAR_FEET?has_content && cp1.MLP_GET_LNR_FT[0].ERROR_CODE == "0")>

        "linear_feet": ${cp1.MLP_GET_LNR_FT[0].TOTAL_LINEAR_FEET},

    <#else>
    </#if>
    "shipment_mode": "${p44.mode!}",
    "dimensions": [
        <#list p44.lineItems as lineItem>
        ${lineItem?is_first?string("",",")}
        {
            "pallets": "${lineItem.totalPackages!0}",
            "lenght": "${lineItem.packageDimensions.length!0}",
            "width": "${lineItem.packageDimensions.width!0}",
            "height": "${lineItem.packageDimensions.height!0}",
            "weight": "${lineItem.totalWeight!0}",
            "stackable": "${lineItem.stackable?string!}",
            "not_turnable": false,
            "freight_class_code": "${lineItem.freightClass!}",
            "packageType": "${lineItem.packageType!}",
            "description": "${lineItem.description!}",
            <#if lineItem.nmfcItemCode?has_content>
                "nmfcItemCode": "${lineItem.nmfcItemCode}",
                <#if lineItem.nmfcSubCode?has_content>
                    "nmfcSubCode": "${lineItem.nmfcSubCode}",
                </#if>
            </#if>
            "countryOfManufacture": "${lineItem.countryOfManufacture!}",
            "harmonizedCode": "${lineItem.harmonizedCode!}",
            "totalValue": "${lineItem.totalValue!0}"

        }
        </#list>
    ],
    "accessorial_charges": [
        <#assign accessorials = p44.directlyCodedAccessorialServices + p44.indirectlyCodedAccessorialServices>
        <#list accessorials as acc>
        {
            "type": "${acc.code!}"
        }<#sep>,
        </#list>
    ]
}