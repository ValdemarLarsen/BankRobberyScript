#include "..\..\script_macros.hpp"
/*
    File: fn_robfederal.sqf
    Author: Valdemar Larsen

    Description:
    Script to rob aa bank. with notifycaation system.
*/
private["_robber","_shop","_kassa","_ui","_progress","_pgText","_cP","_rip","_Pos","_rndmrk","_mrkstring","_bankReward","_reward","_vault"];

_shop = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param; //The object that has the action attached to it is _this. ,0, is the index of object, ObjNull is the default should there be nothing in the parameter or it's broken
_robber = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param; //Can you guess? Alright, it's the player, or the "caller". The object is 0, the person activating the object is 1
_action = [_this,2] call BIS_fnc_param;//Action name
_cops = (west countSide playableUnits);
_vault = param [0,ObjNull,[ObjNull]];
//if(typeOf _vault == "Land_CargoBox_V1_F" && time - (fed_bank getVariable ["reset",time]) < 6400) exitWith {hint "Banken er næsten lige blevet røvet...";};
if(_cops < 0) exitWith {["Der skal være 7 eller flere betjente på!",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem;};
if(side _robber isEqualTo west) exitWith { ["Arrrh, det går sku nok ikke..",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem;};
if(side _robber isEqualTo independent) exitWith { ["Arrrh, det går sku nok ikke..",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; };
if(_robber distance _shop > 25) exitWith { ["Du skal være indenfor 25 Meter!",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; };
if (vehicle player != _robber) exitWith { ["Kom ud af bilen!",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; };
if !(alive _robber) exitWith {};



//Finder ud af hvor guldbar den skal give.
_goldBarAmount = 11;
//round((west countSide playableUnits) * 0.5);
//if (_goldBarAmount > 10) then {_goldBarAmount = 10;};
//if (_goldBarAmount < 3) then {_goldBarAmount = 3;};

if(!([false,"blastingcharge",1] call life_fnc_handleInv)) exitWith { ["Du skal bruge et blastingcharge",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; };
life_inv_blastingcharge = life_inv_blastingcharge - 1;

_shop removeAction _action;
[1,format["ALARM! - %1 Røveri Igang", _shop]] remoteExec ["life_fnc_broadcast",west]; 
remoteExec ['life_fnc_AAN_Bank',-2];
disableSerialization;
5 cutRsc ["life_progress","PLAIN"];
_ui = uiNameSpace getVariable "life_progress";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["Røver banken, Gør plads i din inventory! husk 25 meter! (1%1)...","%"];
_progress progressSetPosition 0.04;
_cP = 0.01;

[1,"BESKED TIL ALLE, BANKEN BLIVER RØVET!!! ALT CIVIL BEVÆGELSE I NÆRHEDEN AF BANKEN KAN FØRE TIL TILBAGEHOLDELSE!!!"] remoteExec ["life_fnc_broadcast",0]; // General broadcast alert to everyone, uncomment for testing, or if you want it anyway.

while{true} do
{
	uiSleep 8;
	_cP = _cP + (0.02 * (missionNamespace getVariable ["mav_ttm_var_robbingMultiplier", 1]));
	_progress progressSetPosition _cP;
	_pgText ctrlSetText format["Røver banken, Gør plads i din inventory! husk 25 meter! (%1%2)...",round(_cP * 100),"%"];

	if(_cP >= 1 OR !alive _robber) exitWith {};
	if(_robber distance _shop > 25) exitWith {};
	if((_robber getVariable["restrained",false])) exitWith {};
	if(life_istazed) exitWith {} ;
	if(life_interrupted) exitWith {};
};


	if!(alive _robber) exitWith {  life_rip = false; call life_fnc_hudUpdate; };
	if(_robber distance _shop > 25) exitWith { ["Du gik for langt væk!",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; 5 cutText ["","PLAIN"]; life_rip = false; call life_fnc_hudUpdate;};
	if(_robber getVariable "restrained") exitWith { life_rip = false; ["Du er blevet anholdt",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; 5 cutText ["","PLAIN"]; call life_fnc_hudUpdate;};
	if(life_istazed) exitWith {  life_rip = false; ["Du er blevet slået ned!",false,15,'Bankrøveri'] spawn DT_fnc_notificationSystem; 5 cutText ["","PLAIN"]; call life_fnc_hudUpdate;};

5 cutText ["","PLAIN"];
titleText[format["Du har stjålet %1 guld bar fra banken, løøøøb!",[_goldBarAmount] call life_fnc_numberText],"PLAIN"];

[true,"goldbar",_goldBarAmount] call life_fnc_handleInv;
[true,"relicFed",1] call life_fnc_handleInv;
fed_bank setVariable["reset",time,true];
//["robbank"] spawn mav_ttm_fnc_addExp;
[] call life_fnc_hudSetup;
[0] call SOCK_fnc_updatePartial;

_rip = false;
life_use_atm = true; // Robber can not use the ATM at this point.
//playSound3D ["A3\Sounds_F\sfx\alarm_independent.wss", player];
if!(alive _robber) exitWith {};
[0,format["Bankrøverne har sjålet %1 guldbar!",[_goldBarAmount] call life_fnc_numberText]] remoteExec ["life_fnc_broadcast",0];
[0,format["Politi Nyheder: Banken er lige blevet røvet, der blev stjålet %1 guldbar !",[_goldBarAmount] call life_fnc_numberText]] remoteExec ["life_fnc_broadcast",0];
[getPlayerUID _robber,name _robber,"19"] remoteExec ["life_fnc_wantedAdd",2];

[] call life_fnc_hudUpdate;
uisleep 10;
_action = _shop addAction["Rob Bank",life_fnc_robShops];

