--Life and Death
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
		once=0
		once2=0
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
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 and Duel.GetFlagEffect(ep,id+1)>0 then return end
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.GetCurrentChain()==0 and once==0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and s[2+tp]>=8000
	local b2=Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and once2==0
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if aux.CheckSkillNegation(e,tp) then return end
	local b1=(Duel.GetFlagEffect(ep,id)==0 and Duel.GetCurrentChain()==0 and once==0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and s[2+tp]>=8000)
	local b2=(Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and once2==0)
	local p=0
	if b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		p=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	if p==0 then
	--shuffle the deck and double damage
		Duel.ShuffleDeck(tp)
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
		--opd register
		Duel.RegisterFlagEffect(ep,id,0,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
	local atk=0
	--target a monster to reduce its atk and gain its lp
		if tc:IsFaceup() then atk=tc:GetAttack() end
			Duel.Recover(tp,atk,REASON_EFFECT)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		once2=1
		--opd register
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	end
end
function s.val(e,re,val,r,rp,rc)
	return math.floor(val*2)
end