--Rage
local s,id=GetID()
function s.initial_effect(c)
	--Activate skill as a quick effect
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
		once=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop()
	for tp=0,1 do
		local current_lp=Duel.GetLP(tp)
		if not s[tp] then s[tp]=current_lp end
		if s[tp]>current_lp then
			s[2+tp]=s[2+tp]+(s[tp]-current_lp)
			s[tp]=current_lp
		elseif s[tp]<current_lp then
			s[tp]=current_lp
		end
	end
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and once==0 -- remove this comment when you upgraded and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- same as up this one and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)
		and s[2+tp]>=8000 --edit if upgraded
end
--operation to double damage, copies from operation to half damage
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then s[2+tp]=0 return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetTargetRange(0,1)
		e1:SetValue(s.val)
--		e1:SetReset(RESET_PHASE|PHASE_END,1)
		Duel.RegisterEffect(e1,tp)
	s[2+tp]=0
	once=1
end

function s.val(e,re,val,r,rp,rc)
	return math.floor(val*2)
end