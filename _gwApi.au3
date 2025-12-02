#include-once
#RequireAdmin
#NoTrayIcon

; AutoIt includes
#include <ScrollBarsConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#include <GuiRichEdit.au3>
#include <GuiEdit.au3>
#include <Array.au3>
#include <Math.au3>
#include <File.au3>
#include <Date.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>

;~ include constants
#include "constants\_constants.au3"

; GwAu3 includes
#include "GwAu3\API\_GwAu3.au3"

; gwApi includes
#include "gwApi\agents.au3"
#include "gwApi\chat.au3"
#include "gwApi\hero.au3"
#include "gwApi\items.au3"
#include "gwApi\map.au3"
#include "gwApi\movement.au3"
#include "gwApi\party.au3"
#include "gwApi\skills.au3"
#include "gwApi\misc.au3"
