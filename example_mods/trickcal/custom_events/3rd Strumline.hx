import psychlua.LuaUtils;
import Note;
import flixel.math.FlxRect;

function onCreatePost()
{
	for (i in 0...8)
        {
            var spr = game.strumLineNotes.members[i];
            spr.setGraphicSize(spr.width / 0.7 * 0.65);
            spr.updateHitbox();
        }
}

function opponentNoteHit(note:Note)
{
	if (note.noteType == 'GF Sing')
	{
		var spr = game.strumLineNotes.members[note.noteData];
		spr.playAnim('static', true);
		spr.resetAnim = 0;
	}
}

function onSpawnNote(note:Note)
{
	if (note.noteType != 'GF Sing')
	{
		if (note.isSustainNote) 
		{
			note.setGraphicSize(note.width / 0.7 * 0.65, note.height);
		}
		else 
		{
			note.setGraphicSize(note.width / 0.7 * 0.65);
		}
			note.updateHitbox();
		if (note.noteType == 'GF Sing')
		{

		}
	}
}