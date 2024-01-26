<#ftl output_format="XML">
<#assign p44 = interactionRecords[0].requestBody>
<#assign auth = p44.vendorAuthentication>

<#function hasContent node>
    <#return node?? && node?has_content && node?trim?has_content>
</#function>

<#function calculateTotalWeightInLbs>
    <#assign totalWeight = 0.00>
    <#assign weightFactor = 1.00>
    <#if p44.weightUnit == "kgs">
        <#assign weightFactor = 2.20462>
    </#if>
    <#list p44.lineItems as item>
        <#assign totalWeight += item.totalWeight * weightFactor>
    </#list>
    <#return totalWeight>
</#function>

<#function calculateTotalPieces>
    <#assign totalPieces = 0>
    <#list p44.lineItems as item>
        <#-- do we sum up item's totalPieces or totalPackeges ? -->
        <#assign totalPieces += item.totalPieces>
    </#list>
    <#return totalPieces>
</#function>

<#function getOriginCountry>
    <#if p44.originLocation.address.country??>
        <#if  p44.originLocation.address.country == "US">
            <#return "USA">
        <#else>
            <#return p44.originLocation.address.country>
        </#if>
     <#else>
        <#return "">
    </#if>    
</#function>

<#function getDestinationCountry>
    <#if p44.destinationLocation.address.country??>
        <#if  p44.destinationLocation.address.country == "US">
            <#return "USA">
        <#else>
            <#return p44.destinationLocation.address.country>
        </#if>
     <#else>
        <#return "">
    </#if>    
</#function>

<#function buildNote>
    <#assign note = "">
    <#if p44.pickupNote?has_content>
        <#assign note += "pickup note: ${p44.pickupNote}">
    </#if>
    <#if p44.deliveryNote?has_content>
        <#if note != "">
            <#assign note += ",\n">
        </#if>
        <#assign note += "delivery note: ${p44.deliveryNote}">
    </#if>
    <#return note>
</#function>

<#function tryAccCode accCode="">
    <#if accCodes?seq_contains(accCode)>
        <#return "1">
    <#else> 
        <#return "0">
    </#if>
</#function>

<#assign accCodes = [ ]>
<#list p44.directlyCodedAccessorialServices as acc>
    <#assign accCodes = accCodes + [ acc.code ]>
</#list>



<?xml version="1.0" encoding="ISO-8859-1"?>
<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
    <SOAP-ENV:Body>
        <ns6809:GetQuote xmlns:ns6809="http://tempuri.org">
            <#-- Hardcoded values, should not be shared with customers!   -->
            <freight_token xsi:type="xsd:string">35987083</freight_token>
            <regkey xsi:type="xsd:string">383105293</regkey>
            <#-- 6 digit number unique for every customer   -->
            <bill_to_id xsi:type="xsd:string">${p44.vendorAuthentication.accountNumber1!0}</bill_to_id>
            <pickup_details>
                <pickup_zip xsi:type="xsd:string">${p44.originLocation.address.postalCode!0}</pickup_zip>
                <pickup_cntry xsi:type="xsd:string">${getOriginCountry()}</pickup_cntry>
                <#--  is needed AM and PM support ?  -->
                <pickup_date xsi:type="xsd:string">${p44.pickupWindow.date!}</pickup_date>
                <pickup_time xsi:type="xsd:string">${p44.pickupWindow.startTime!}</pickup_time>
                <pickup_lift_gate xsi:type="xsd:string">${tryAccCode("LGPU")}</pickup_lift_gate>
                <pickup_residential xsi:type="xsd:string">${tryAccCode("RESPU")}</pickup_residential>
                <pickup_inside xsi:type="xsd:string">${tryAccCode("INPU")}</pickup_inside>
                <pickup_palletjack xsi:type="xsd:string">${tryAccCode("PJACKPU")}</pickup_palletjack>
                <pickup_driver_assist xsi:type="xsd:string">${tryAccCode("LOAD")}</pickup_driver_assist>
            </pickup_details>
            <deliverto_details>
                <deliverto_zip xsi:type="xsd:string">${p44.destinationLocation.address.postalCode!0}</deliverto_zip>
                <deliverto_cntry xsi:type="xsd:string">${getDestinationCountry()}</deliverto_cntry>
                <deliverto_lift_gate xsi:type="xsd:string">${tryAccCode("LGDEL")}</deliverto_lift_gate>
                <deliverto_residential xsi:type="xsd:string">${tryAccCode("RESDEL")}</deliverto_residential>
                <deliverto_inside xsi:type="xsd:string">${tryAccCode("INDEL")}</deliverto_inside>
                <deliverto_palletjack xsi:type="xsd:string">${tryAccCode("PJACKDEL")}</deliverto_palletjack>
                <deliverto_driver_assist xsi:type="xsd:string">${tryAccCode("UNLOAD")}</deliverto_driver_assist>
            </deliverto_details>
            <pieces xsi:type="xsd:string">${calculateTotalPieces()}</pieces>
            <weight_lbs xsi:type="xsd:string">${calculateTotalWeightInLbs()}</weight_lbs>
            <notes xsi:type="xsd:string">${buildNote()}</notes>
            <google_driving_miles xsi:type="xsd:string"></google_driving_miles>
            <item_details>
                <items xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="unnamed_struct_use_soapval[2]">
                <#list p44.lineItems as lineItem>
                   <item>  
                        <pieces xsi:type="xsd:int">${lineItem.totalPieces!0}</pieces>
                        <weight xsi:type="xsd:int">${lineItem.totalWeight!0}</weight>
                        <length xsi:type="xsd:int">${lineItem.packageDimensions.length!0}</length>
                        <height xsi:type="xsd:int">${lineItem.packageDimensions.height!0}</height>
                        <width xsi:type="xsd:int">${lineItem.packageDimensions.width!0}</width>
                   </item>
                </#list>
                </items>
            </item_details>
            <bill_to_comp_name xsi:type="xsd:string">${p44.vendorAccountSettings.billToLocation.contact.companyName!}</bill_to_comp_name>
            <bill_to_add xsi:type="xsd:string">${p44.vendorAccountSettings.billToLocation.address.addressLines[0]!}</bill_to_add>
        </ns6809:GetQuote>
    </SOAP-ENV:Body>
</SOAP-ENV:Envelope>