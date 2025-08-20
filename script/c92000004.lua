--Intense Heat
--by Coyot23 for Rogue God
local s,id=GetID()
local COUNTER_AURA=0x1100
function s.initial_effect(c)
	c:EnableCounterPermit(0x1100)	--Can place Kickfire Counters on it
	--when activated, you can discard to draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_FIRE) end)
	e3:SetValue(function(e,c) return e:GetHandler():GetCounter(COUNTER_AURA)*200 end)
	c:RegisterEffect(e3)
end
function s.filter(c) --filter for a discardable fire monster
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost() and c:IsDiscardable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		and Duel.IsPlayerCanDraw(tp,2)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1))
		and Duel.DiscardHand(tp,s.filter,1,1,REASON_DISCARD|REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep~=tp then return end
	local ct=1
	c:AddCounter(0x1100,ct)
end
