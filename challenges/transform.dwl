%dw 2.0

var sourceLineItems = payload.data.order.lineItems map ($ ++ {
    "isRootItem": !isEmpty($.custom.customFieldsRaw[?($.name == "isMainLineItem" and $.value)]),
    "configuratorId": $.custom.customFieldsRaw[?($.name == "configuratorId")][0].value default null
})

var rootLevelItems = sourceLineItems[?($.isRootItem)]
var nonRootLevelItems = sourceLineItems[?(!($.isRootItem))]

fun findMyChilds(configuratorId) = (
    (nonRootLevelItems[?($.configuratorId == configuratorId)] map { id: $.id })  default [] 
)

//output application/json
output application/dw
---
{
    order: {
        count: sizeOf(rootLevelItems) default 0,
        lineItems: rootLevelItems map {
            id: $.id,
            childs: findMyChilds($.configuratorId)
        }
    }
}
