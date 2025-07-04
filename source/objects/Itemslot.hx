package objects;

class Itemslot extends FlxSpriteGroup {
    public var item(default, set):FlxSprite;
    public var itemslot:FlxSprite;
    public var itemslotType(default, set):ItemslotType;

    public function new(x:Float, y:Float, item:FlxSprite, itemslotType:ItemslotType = FIRST) {
        super(x, y);

        itemslot = new FlxSprite();
        this.itemslotType = itemslotType;
        this.item = item;
    }

    function set_item(spr:FlxSprite):FlxSprite {
        spr.setGraphicSize(itemslot.width - itemslot.width / 1.5, itemslot.height - itemslot.height / 1.5);
        spr.updateHitbox();
        spr.setPosition(itemslot.width / 2 - spr.width / 2, itemslot.height / 2 - spr.height / 2);
        return item = spr;
    }

    function set_itemslotType(type:ItemslotType):ItemslotType {
        itemslot.loadGraphic(Paths.image('itemslot/$type'));
        itemslot.updateHitbox();
        return itemslotType = type;
    }
}

enum abstract ItemslotType(String) {
    var FIRST = 'first';
}