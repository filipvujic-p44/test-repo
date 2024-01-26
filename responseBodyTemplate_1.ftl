 <#compress>
 
<#setting number_format="computer">

<#assign cpString = interactionRecords[0].vendorResponseBodyString>

<#function hasContent node = "" >
    <#return node?has_content && node?trim?has_content>
</#function>

<#function getTagValueFromResponseBodyString(tagName)>
  <#assign startTag = "<" + tagName + ">" />
  <#assign endTag = "</" + tagName + ">" />
  <#return cpString?keep_before(endTag)?keep_after(startTag)>
</#function>

<#function convertTransitHoursToTransitDays>
    <#assign transitTime = getTagValueFromResponseBodyString("Transit_time")>
    <#if transitTime?has_content>
    {
        <#attempt>
            <#assign transitHours = transitTime?keep_before(" hours")?trim?number>
        <#recover>
            <#return "-1">
        </#attempt>

        <#if transitHours?has_content>
        {
            <#assign transitDays = (transitHours/24)?round>
            <#assign hoursRemainer = transitHours % 24>
            <#if hoursRemainer gt 12>
                <#assign transitDays++>
            </#if>
            <#return transitDays>
        }
        </#if>
    }
    </#if>
    <#return "-1">
</#function>

<#function convertDateTimeFormat dateTime="">
    <#assign dateTime = dateTime?lower_case>

    <#if (dateTime?contains("am") || dateTime?contains("pm"))>
        <#attempt>
            <#assign parsedDate = dateTime?datetime("MM/dd/yyyy h:mm:ss a")>
            <#return parsedDate?string("yyyy-MM-dd'T'HH:mm:ss")>
        <#recover>
            <#return "-1">
        </#attempt>
    <#else>
        <#return dateTime>
    </#if>
</#function>

<#function getDeliveryDateTime>
    <#return convertDateTimeFormat(getTagValueFromResponseBodyString("ExpectedDeliveryDate"))>
</#function>

<#function getQuoteEffectiveDateTime>
    <#return convertDateTimeFormat(getTagValueFromResponseBodyString("Quote_datetime"))>
</#function>


<#if !cpString?has_content || !cpString?starts_with("<?xml")>
{
"infoMessages": [],
"warningMessages": [],
"errorMessages": [{"ourCode": "VENDOR_INVALID_RESPONSE"}]
}
<#else>
{
    <#assign errMsg = getTagValueFromResponseBodyString("Error")>
    <#if errMsg?has_content>
    {
        "infoMessages": [],
        "warningMessages": [],
        "errorMessages": [{
            "ourCode": "VENDOR_RATING_GENERAL",
            "message": "${errMsg}"
        }] 
    }
    <#else>
    {
        "rateQuotes":[{
            "carrierCode":"FEXM",
            "serviceLevel":{},
            "transitDays": ${convertTransitHoursToTransitDays()},
            "deliveryDateTime": ${getDeliveryDateTime()},
            "rateQuoteDetail":{
                "total":${getTagValueFromResponseBodyString("Quote_price")?replace("$","")?replace(",","")},
                "charges":[
                    {
                        "ourCode":"GFC",
                        "amount":,
                        "lineItem":{
                            "packageDimensions":{},
                            "totalPackages":0,
                            "totalPieces":0,
                            "stackable":true
                        }
                    }
                ]
            },
            "alternateRateQuotes":[],
            "originTerminal":{},
            "destinationTerminal":{},
            "quoteEffectiveDateTime": ${getQuoteEffectiveDateTime()},
            "quoteExpirationDateTime":{},
            "unacceptedAccessorialServiceCodes":[],

            "infoMessages":[],
            "warningMessages":[],
            "errorMessages":[]
        }],
        "infoMessages":[],
        "warningMessages":[],
        "errorMessages":[]
        }
    }
    </#if>
}
</#if>
</#compress>