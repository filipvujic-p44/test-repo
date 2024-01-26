<#compress>
	<#setting number_format="computer">
	<#attempt>
		<#assign cp = interactionRecords[1].vendorResponseBody>
	<#recover>
		<#assign cp = "">
	</#attempt>
	<#function hasContent node>
	<#return node?? && node?has_content && node?trim?has_content>
	</#function>
	<#if !cp?has_content>
		{
			"rateQuotes": [],
			"infoMessages": [],
			"warningMessages": [],
			"errorMessages": [{
				"ourCode": "VENDOR_INVALID_RESPONSE",
				"message": ""
			}
			]
		}
	<#elseif cp?has_content && cp.status?has_content && cp.status?string?trim=="false">
		{
			"rateQuotes": [],
			"infoMessages": [],
			"warningMessages": [],
			"errorMessages": [{
				"ourCode": "VENDOR_RATING_GENERAL",
				"message": "${cp.msg!}"
			}
			]
		}
	<#else>
		{
			"rateQuotes": [{
				"carrierCode": "GTJN",
				"quoteNumber": "${cp.quote_number!}",
				"serviceLevel":{
					"ourCode": "STD",
					"description": "LTL Standard Transit"
				},
				"transitDays": "${cp.transitDays!0}",
				"currencyCode": "USD",
				"rateQuoteDetail":{
					"total": "${cp.total!0}",
				"charges": [{
					"ourCode": "GFC",
					"amount": "${cp.rate!0}"
				},
				{
					"ourCode": "FSC",
					"amount": "${cp.fuel_surcharge!0}"
				},
				{
					"ourCode": "ACC",
					"amount": "${cp.Accesorial_charge!0}"
			}
			]
		}
	}
	],
	"infoMessages": [],
	"warningMessages": [],
	"errorMessages": []
}
</#if>
</#compress>