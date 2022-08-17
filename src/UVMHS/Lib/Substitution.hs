module UVMHS.Lib.Substitution where

import UVMHS.Core
import UVMHS.Lib.Variables
import UVMHS.Lib.Pretty
import UVMHS.Lib.Parser
import UVMHS.Lib.Rand

--------------------------
-- SUBSTITUTION ELEMENT --
--------------------------

-- ℯ ⩴ s⇈e
data SubstElem s a = SubstElem
  { substElemIntro ∷ s ⇰ ℕ64
  , substElemValue ∷ () → 𝑂 a
  } deriving (Eq,Ord,Show)
makeLenses ''SubstElem

instance (Pretty s,Pretty a) ⇒ Pretty (SubstElem s a) where
  pretty (SubstElem s ueO) = ppInfr pASC (ppPun "⇈") (pretty s) $
    ifNone (ppPun "⊥") $ pretty ^$ ueO ()

instance (Ord s,Fuzzy s,Fuzzy a) ⇒ Fuzzy (SubstElem s a) where
  fuzzy = do
    𝑠 ← fuzzy
    ueO ← fuzzy
    return $ SubstElem 𝑠 ueO

introSubstElem ∷ (Ord s) ⇒ s ⇰ ℕ64 → SubstElem s a → SubstElem s a
introSubstElem = alter substElemIntroL ∘ (+)

subSubstElem ∷ (s ⇰ ℕ64 → a → 𝑂 a) → SubstElem s a → SubstElem s a
subSubstElem substE (SubstElem 𝑠 ueO) = SubstElem zero $ \ () → substE 𝑠 *$ ueO ()

--------------------------------
-- SCOPED SUBSTITUION ELEMENT --
--------------------------------

-- ℯ ⩴ i | s⇈e
data SSubstElem s a = 
    Var_SSE ℕ64
  | Trm_SSE (SubstElem s a)
  deriving (Eq,Ord,Show)

instance (Pretty s,Pretty a) ⇒ Pretty (SSubstElem s a) where
  pretty = \case
    Var_SSE i → pretty $ DVar i
    Trm_SSE e → pretty e

instance (Ord s,Fuzzy s,Fuzzy a) ⇒ Fuzzy (SSubstElem s a) where 
  fuzzy = rchoose
    [ \ () → Var_SSE ^$ fuzzy
    , \ () → Trm_SSE ^$ fuzzy
    ]

introSSubstElem ∷ (Ord s) ⇒ s → s ⇰ ℕ64 → SSubstElem s e → SSubstElem s e
introSSubstElem s 𝑠 = \case
  Var_SSE n → Var_SSE $ n + ifNone 0 (𝑠 ⋕? s)
  Trm_SSE e → Trm_SSE $ introSubstElem 𝑠 e

subSSubstElem ∷ (ℕ64 → SSubstElem s e) → (s ⇰ ℕ64 → e → 𝑂 e) → SSubstElem s e → SSubstElem s e
subSSubstElem substV substE = \case
  Var_SSE n → substV n
  Trm_SSE ℯ → Trm_SSE $ subSubstElem substE ℯ

----------------------------
-- DE BRUIJN SUBSTITUTION --
----------------------------

-- 𝓈 ⩴ ⟨ρ,es,ι⟩ 
-- INVARIANT: |es| + ι ≥ 0
data DSubst s e = DSubst
  { dsubstShift ∷ ℕ64
  , dsubstElems ∷ 𝕍 (SSubstElem s e)
  , dsubstIntro ∷ ℤ64
  } deriving (Eq,Ord,Show)
makeLenses ''DSubst
makePrettyRecord ''DSubst

instance (Ord s,Fuzzy s,Fuzzy a) ⇒ Fuzzy (DSubst s a) where 
  fuzzy = do
    ρ ← fuzzy
    𝔰 ← fuzzy
    es ← mapMOn (vecF 𝔰 id) $ const $ fuzzy
    ι ← randr (neg $ intΩ64 𝔰) $ intΩ64 𝔰
    return $ DSubst ρ es ι

isNullDSubst ∷ DSubst s e → 𝔹
isNullDSubst (DSubst _ρ es ι) = csize es ≡ 0 ⩓ ι ≡ 0

-- 𝓈 ≜ ⟨ρ,es,ι⟩
-- 𝔰 ≜ |es|
-- 𝓈(i) ≜
--   cases (disjoint):
--     |       i < ρ   ⇒ i
--     |   ρ ≤ i < ρ+𝔰 ⇒ es[i-ρ]
--     | ρ+𝔰 ≤ i       ⇒ i+ι
-- 𝓈(i) ≜
--   cases (sequential):
--     | i < ρ   ⇒ i
--     | i < ρ+𝔰 ⇒ es[i-ρ]
--     | ⊤       ⇒ i+ι
-- e.g.,
-- 𝓈 = ⟨2,[e],-1⟩
-- 𝓈 is logically equivalent to the (infinite) substitution vector
-- [ …
-- ,  0 ↦ ⌊ 0⌋    | ≡
-- ,  1 ↦ ⌊ 1⌋    |
-- ----------------
-- ,  2 ↦   e     | [e]
-- ----------------
-- ,  3 ↦ ⌊ 2⌋    | -1
-- ,  4 ↦ ⌊ 3⌋    |
-- , …
-- ]
dsubstVar ∷ DSubst 𝑠 e → ℕ64 → SSubstElem 𝑠 e
dsubstVar (DSubst ρ̇ es ι) ṅ =
  let 𝔰̇  = csize es
      n  = intΩ64 ṅ
  in 
  if
  | ṅ < ρ̇     → Var_SSE ṅ
  | ṅ < 𝔰̇+ρ̇   → es ⋕! (ṅ-ρ̇)
  | otherwise → Var_SSE $ natΩ64 $ n+ι

-------------------------------
-- GENERIC SCOPED SUBSTITUTION --
-------------------------------

data GSubst s₁ s₂ e = GSubst 
  { gsubstGlobal ∷ s₁ ⇰ SubstElem s₂ e
  , gsubstScoped ∷ s₂ ⇰ DSubst s₂ e 
  } 
  deriving (Eq,Ord,Show)
makeLenses ''GSubst
makePrettyUnion ''GSubst

instance (Ord s₁,Ord s₂,Fuzzy s₁,Fuzzy s₂,Fuzzy a) ⇒ Fuzzy (GSubst s₁ s₂ a) where 
  fuzzy = do
    esᴳ ← fuzzy
    𝓈 ← fuzzy
    return $ GSubst esᴳ 𝓈

𝓈shiftG ∷ (Ord s₂) ⇒ s₂ ⇰ ℕ64 → GSubst s₁ s₂ e → GSubst s₁ s₂ e
𝓈shiftG 𝑠 (GSubst esᴳ 𝓈s) = 
  let 𝓈s' = mapWithKeyOn 𝓈s $ \ s (DSubst ρ es ι) →
        let ρ'  = ρ + ifNone 0 (𝑠 ⋕? s)
            es' = mapOn es $ introSSubstElem s 𝑠
        in DSubst ρ' es' ι
      esᴳ' = mapOn esᴳ $ introSubstElem 𝑠
  in GSubst esᴳ' 𝓈s'

𝓈introG ∷ s₂ ⇰ ℕ64 → GSubst s₁ s₂ e
𝓈introG 𝑠 = GSubst null $ mapOn 𝑠 $ DSubst 0 null ∘ intΩ64

𝓈sbindsG ∷ s₂ ⇰ 𝕍 e → GSubst s₁ s₂ e
𝓈sbindsG ess = GSubst null $ mapOn ess $ \ es →
  let ℯs = map (Trm_SSE ∘ SubstElem null ∘ const ∘ return) es
      ι  = neg $ intΩ64 $ csize es
  in DSubst zero ℯs ι

𝓈sbindG ∷ (Ord s₂) ⇒ s₂ → e → GSubst s₁ s₂ e
𝓈sbindG s e = 𝓈sbindsG $ s ↦ single e

𝓈gbindsG ∷ s₁ ⇰ e → GSubst s₁ s₂ e
𝓈gbindsG esᴳ = GSubst (map (SubstElem null ∘ const ∘ return) esᴳ) null

𝓈gbindG ∷ (Ord s₁) ⇒ s₁ → e → GSubst s₁ s₂ e
𝓈gbindG s e = 𝓈gbindsG $ s ↦ e

-- 𝓈₁ ≜ ⟨ρ₁,es₁,ι₁⟩
-- 𝓈₂ ≜ ⟨ρ₂,es₂,ι₂⟩
-- 𝔰₁ = |es₁| 
-- 𝔰₂ = |es₂| 
-- (𝓈₂⧺𝓈₁)(i) 
-- ==
-- 𝓈₂(𝓈₁(i))
-- ==
-- cases (sequential):
--   | i < ρ₁    ⇒ 𝓈₂(i)
--   | i < ρ₁+𝔰₁ ⇒ 𝓈₂(es₁[i-ρ₁])
--   | ⊤         ⇒ 𝓈₂(i+ι₁)
-- ==
-- cases (sequential):
--   | i < ρ₁    ⇒ cases (sequential):
--                    | i < ρ₂    ⇒ i
--                    | i < ρ₂+𝔰₂ ⇒ es₂[i-ρ₂]
--                    | ⊤         ⇒ i+ι₂
--   | i < ρ₁+𝔰₁ ⇒ 𝓈₂(es₁[i-ρ₁])
--   | ⊤         ⇒ cases (sequential):
--                    | i < ρ₂-ι₁    ⇒ i+ι₁
--                    | i < ρ₂+𝔰₂-ι₁ ⇒ es₂[i+ι₁-ρ₂]
--                    | ⊤            ⇒ i+ι₁+ι₂
-- ==
-- cases (sequential):
--   | i < ρ₁⊓ρ₂      ⇒ i
--   ---------------------------------
--   | i < ρ₁⊓(ρ₂+𝔰₂) ⇒ es₂[i-ρ₂]
--   | i < ρ₁         ⇒ i+ι₂
--   | i < ρ₁+𝔰₁      ⇒ 𝓈₂(es₁[i-ρ₁])
--   | i < ρ₂-ι₁      ⇒ i+ι₁
--   | i < ρ₂+𝔰₂-ι₁   ⇒ es₂[i+ι₁-ρ₂]
--   ---------------------------------
--   | ⊤              ⇒ i+ι₁+ι₂
-- == ⟨ρ,es,ι⟩(i)
-- where
--     ρ = ρ₁⊓ρ₂
--     ι = ι₁+ι₂
--     𝔰 ≜ |es|
--   ρ+𝔰 = (ρ₁+𝔰₁)⊔(ρ₂+𝔰₂-ι₁)
--     𝔰 = ((ρ₁+𝔰₁)⊔(ρ₂+𝔰₂-ι₁))-ρ
appendGSubst ∷ 
  (Ord s₁,Ord s₂) 
  ⇒ (GSubst s₁ s₂ e → e → 𝑂 e) 
  → GSubst s₁ s₂ e 
  → GSubst s₁ s₂ e 
  → GSubst s₁ s₂ e
appendGSubst esubst 𝓈̂₂ 𝓈̂₁ =
  let GSubst esᴳ₁ 𝓈s₁ = 𝓈̂₁
      GSubst esᴳ₂ 𝓈s₂ = 𝓈̂₂
      esub 𝓈 𝑠 = esubst $ appendGSubst esubst 𝓈 $ 𝓈introG 𝑠
      ℯsub s 𝓈 = subSSubstElem (elim𝑂 Var_SSE dsubstVar $ gsubstScoped 𝓈 ⋕? s) $ esub 𝓈
      esᴳ₁' = mapOn esᴳ₁ $ subSubstElem $ esub 𝓈̂₂
      esᴳ = esᴳ₁' ⩌ esᴳ₂ 
      𝓈s₁' = mapWithKeyOn 𝓈s₁ $ \ s (DSubst ρ̇₁ es₁ ι₁) → DSubst ρ̇₁ (mapOn es₁ $ ℯsub s 𝓈̂₂) ι₁
      𝓈s = unionWithOn 𝓈s₂ 𝓈s₁' $ \ 𝓈₂@(DSubst ρ̇₂ es₂ ι₂) 𝓈₁@(DSubst ρ̇₁ es₁ ι₁) →
        if
        | isNullDSubst 𝓈₁ → 𝓈₂
        | isNullDSubst 𝓈₂ → 𝓈₁
        | otherwise →
            let 𝔰₁ = intΩ64 $ csize es₁
                𝔰₂ = intΩ64 $ csize es₂
                ρ₁ = intΩ64 ρ̇₁
                ρ₂ = intΩ64 ρ̇₂
                ρ̇  = ρ̇₁⊓ρ̇₂
                ρ  = intΩ64 ρ̇
                ι  = ι₁+ι₂
                𝔰  = ((ρ₁+𝔰₁)⊔(ρ₂+𝔰₂-ι₁))-ρ
                δ  = ρ
                es = vecF (natΩ64 𝔰) $ \ ṅ → 
                  let n = intΩ64 ṅ + δ in 
                  if
                  | n < ρ₁⊓(ρ₂+𝔰₂) → es₂ ⋕! natΩ64 (n-ρ₂)
                  | n < ρ₁         → Var_SSE $ natΩ64 $ n+ι₂
                  | n < ρ₁+𝔰₁      → es₁ ⋕! natΩ64 (n-ρ₁)
                  | n < ρ₂-ι₁      → Var_SSE $ natΩ64 $ n+ι₁
                  | n < ρ₂+𝔰₂-ι₁   → es₂ ⋕! natΩ64 (n+ι₁-ρ₂)
                  | otherwise      → error "bad"
            in
            DSubst ρ̇ es ι
  in GSubst esᴳ 𝓈s

-------------------------------------------
-- SUBSTY (STANDARD SCOPED SUBSTITUTION) --
-------------------------------------------

newtype Subst s e = Subst { unSubst ∷ GSubst 𝕏 (s ∧ 𝑂 𝕏) e }
  deriving (Eq,Ord,Show,Pretty,Fuzzy)
makeLenses ''Subst

data FreeVars s = FreeVars
  { freeVarsGlobal ∷ 𝑃 𝕏
  , freeVarsScoped ∷ (s ∧ 𝑂 𝕏) ⇰ 𝑃 ℕ64
  } deriving (Eq,Ord,Show)
makeLenses ''FreeVars
makePrettyRecord ''FreeVars

instance Null (FreeVars s) where 
  null = FreeVars null null
instance (Ord s) ⇒ Append (FreeVars s) where 
  FreeVars xs₁ sys₁ ⧺ FreeVars xs₂ sys₂ = FreeVars (xs₁ ⧺ xs₂) $ sys₁ ⧺ sys₂
instance (Ord s) ⇒ Monoid (FreeVars s)

data SubstAction s e = SubstAction
  { substActionRebnd ∷ 𝑂 𝔹
  , substActionSubst ∷ Subst s e
  }
makeLenses ''SubstAction

data SubstEnv s e = 
    FVsSubstEnv ((s ∧ 𝑂 𝕏) ⇰ ℕ64)
  | SubSubstEnv (SubstAction s e)
makePrisms ''SubstEnv

newtype SubstM s e a = SubstM 
  { unSubstM ∷ UContT (ReaderT (SubstEnv s e) (FailT (WriterT (FreeVars s) ID))) a 
  } deriving
  ( Return,Bind,Functor,Monad
  , MonadUCont
  , MonadReader (SubstEnv s e)
  , MonadWriter (FreeVars s)
  , MonadFail
  )

runSubstM ∷ SubstEnv s e → SubstM s e a → FreeVars s ∧ 𝑂 a
runSubstM γ = unID ∘ unWriterT ∘ unFailT ∘ runReaderT γ ∘ evalUContT ∘ unSubstM

class Substy s e a | a→s,a→e where
  substy ∷ a → SubstM s e a

subst ∷ (Substy s e a) ⇒ Subst s e → a → 𝑂 a
subst 𝓈 = snd ∘ runSubstM (SubSubstEnv $ SubstAction None 𝓈) ∘ substy

todbr ∷ (Substy s e a) ⇒ a → 𝑂 a
todbr = snd ∘ runSubstM (SubSubstEnv $ SubstAction (Some True) null) ∘ substy

tonmd ∷ (Substy s e a) ⇒ a → 𝑂 a
tonmd = snd ∘ runSubstM (SubSubstEnv $ SubstAction (Some False) null) ∘ substy

freev ∷ (Substy s e a) ⇒ a → FreeVars s
freev = fst ∘ runSubstM (FVsSubstEnv null) ∘ substy

nullSubst ∷ Subst s e
nullSubst = Subst $ GSubst null null

appendSubst ∷ (Ord s,Substy s e e) ⇒ Subst s e → Subst s e → Subst s e
appendSubst 𝓈₂ 𝓈₁ = Subst $ appendGSubst (subst ∘ Subst) (unSubst 𝓈₂) $ unSubst 𝓈₁

instance                        Null   (Subst s e) where null = nullSubst
instance (Ord s,Substy s e e) ⇒ Append (Subst s e) where (⧺)  = appendSubst
instance (Ord s,Substy s e e) ⇒ Monoid (Subst s e)

𝓈sdshift ∷ (Ord s) ⇒ s ⇰ ℕ64 → Subst s e → Subst s e
𝓈sdshift = alter unSubstL ∘ 𝓈shiftG ∘ assoc ∘ map (mapFst $ flip (:*) None) ∘ iter

𝓈snshift ∷ (Ord s) ⇒ s ⇰ 𝕏 ⇰ ℕ64 → Subst s e → Subst s e
𝓈snshift 𝑠 = alter unSubstL $ 𝓈shiftG $ assoc $ do
  s :* xns ← iter 𝑠
  x :* n ← iter xns
  return $ s :* Some x :* n

𝓈sdintro ∷ (Ord s) ⇒ s ⇰ ℕ64 → Subst s e
𝓈sdintro = Subst ∘ 𝓈introG ∘ assoc ∘ map (mapFst $ flip (:*) None) ∘ iter

𝓈snintro ∷ (Ord s) ⇒ s ⇰ 𝕏 ⇰ ℕ64 → Subst s e
𝓈snintro 𝑠 = Subst $ 𝓈introG $ assoc $ do
  s :* xns ← iter 𝑠
  x :* n ← iter xns
  return $ s :* Some x :* n

𝓈sdbinds ∷ (Ord s) ⇒ s ⇰ 𝕍 e → Subst s e
𝓈sdbinds = Subst ∘ 𝓈sbindsG ∘ assoc ∘ map (mapFst $ flip (:*) None) ∘ iter

𝓈sdbind ∷ (Ord s) ⇒ s → e → Subst s e
𝓈sdbind s e = 𝓈sdbinds $ s ↦ single e

𝓈snbinds ∷ (Ord s) ⇒ s ⇰ 𝕏 ⇰ 𝕍 e → Subst s e
𝓈snbinds 𝑠 = Subst $ 𝓈sbindsG $ assoc $ do
  s :* xess ← iter 𝑠
  x :* es ← iter xess
  return $ s :* Some x :* es

𝓈snbind ∷ (Ord s) ⇒ s → 𝕏 → e → Subst s e
𝓈snbind s x e = 𝓈snbinds $ s ↦ x ↦ single e

𝓈gbinds ∷ (Ord s) ⇒ 𝕏 ⇰ e → Subst s e
𝓈gbinds = Subst ∘ 𝓈gbindsG

𝓈gbind ∷ (Ord s) ⇒ 𝕏 → e → Subst s e
𝓈gbind x e = 𝓈gbinds $ x ↦ e

𝓈dshift ∷ ℕ64 → Subst () e → Subst () e
𝓈dshift = 𝓈sdshift ∘ (↦) ()

𝓈nshift ∷ 𝕏 ⇰ ℕ64 → Subst () e → Subst () e
𝓈nshift = 𝓈snshift ∘ (↦) ()

𝓈dintro ∷ ℕ64 → Subst () e
𝓈dintro = 𝓈sdintro ∘ (↦) ()

𝓈nintro ∷ 𝕏 ⇰ ℕ64 → Subst () e
𝓈nintro = 𝓈snintro ∘ (↦) ()

𝓈dbinds ∷ 𝕍 e → Subst () e
𝓈dbinds = 𝓈sdbinds ∘ (↦) ()

𝓈dbind ∷ e → Subst () e
𝓈dbind = 𝓈sdbind ()

𝓈nbinds ∷ 𝕏 ⇰ 𝕍 e → Subst () e
𝓈nbinds = 𝓈snbinds ∘ (↦) ()

𝓈nbind ∷ 𝕏 → e → Subst () e
𝓈nbind = 𝓈snbind ()

substyDBdr ∷ (Ord s) ⇒ s → SubstM s e ()
substyDBdr s = umodifyEnv $ compose
  [ alter subSubstEnvL $ alter substActionSubstL $ 𝓈sdshift $ s ↦ 1
  , alter fVsSubstEnvL $ (⧺) $ (s :* None) ↦ 1
  ]

substyNBdr ∷ (Ord s) ⇒ s → 𝕏 → SubstM s e ()
substyNBdr s x = umodifyEnv $ compose
  [ alter subSubstEnvL $ alter substActionSubstL $ 𝓈snshift $ s ↦ x ↦ 1
  , alter fVsSubstEnvL $ (⧺) $ (s :* Some x) ↦ 1
  ]

substyBdr ∷ (Ord s,Substy s e e) ⇒ s → 𝕏 → (𝕐 → e) → SubstM s e ()
substyBdr s x 𝓋 = do
  substyDBdr s
  substyNBdr s x
  bO ← access substActionRebndL *∘ view subSubstEnvL ^$ ask
  case bO of
    None → skip
    Some b → do
      if b 
      then
        umodifyEnv $ alter subSubstEnvL $ alter substActionSubstL $ flip (⧺) $ concat
          [ 𝓈snintro $ s ↦ x ↦ 1
          , 𝓈snbind s x $ 𝓋 $ DVar 0
          ]
      else
        umodifyEnv $ alter subSubstEnvL $ alter substActionSubstL $ flip (⧺) $ concat
          [ 𝓈sdintro $ s ↦ 1
          , 𝓈sdbind s $ 𝓋 $ NVar 0 x
          ]

substyVar ∷ (Ord s,Substy s e e) ⇒ 𝑂 𝕏 → s → (ℕ64 → e) → ℕ64 → SubstM s e e
substyVar xO s 𝓋 n = do
  γ ← ask
  case γ of
    FVsSubstEnv 𝑠 → do
      let n₀ = ifNone 0 (𝑠 ⋕? (s :* xO))
      when (n ≥ n₀) $ do
        tell $ FreeVars null $ (s :* xO) ↦ single (n-n₀)
      return $ 𝓋 n
    SubSubstEnv 𝓈A → do
      let 𝓈s = gsubstScoped $ unSubst $ substActionSubst 𝓈A
      case 𝓈s ⋕? (s :* xO) of
        None → return $ 𝓋 n
        Some 𝓈 → case dsubstVar 𝓈 n of
          Var_SSE n' → return $ 𝓋 n'
          Trm_SSE (SubstElem 𝑠 ueO) → failEff $ subst (Subst $ 𝓈introG 𝑠) *$ ueO ()

substyDVar ∷ (Ord s,Substy s e e) ⇒ s → (ℕ64 → e) → ℕ64 → SubstM s e e
substyDVar = substyVar None

substyNVar ∷ (Ord s,Substy s e e) ⇒ s → (ℕ64 → e) → 𝕏 → ℕ64 → SubstM s e e
substyNVar s 𝓋 x = substyVar (Some x) s 𝓋

substyGVar ∷ (Ord s,Substy s e e) ⇒ (𝕏 → e) → 𝕏 → SubstM s e e
substyGVar 𝓋 x = do
  γ ← ask
  case γ of
    FVsSubstEnv _𝑠 → do
      tell $ FreeVars (single x) null
      return $ 𝓋 x
    SubSubstEnv 𝓈A → do
      let gsᴱ =  gsubstGlobal $ unSubst $ substActionSubst 𝓈A
      case gsᴱ ⋕? x of
        None → return $ 𝓋 x
        Some (SubstElem 𝑠 ueO) → failEff $ subst (Subst $ 𝓈introG 𝑠) *$ ueO ()

substy𝕐 ∷ (Ord s,Substy s e e) ⇒ s → (𝕐 → e) → 𝕐 → SubstM s e e
substy𝕐 s 𝓋 = \case
  DVar n   → substyDVar s (𝓋 ∘ DVar)        n
  NVar n x → substyNVar s (𝓋 ∘ flip NVar x) x n
  GVar   x → substyGVar   (𝓋 ∘ GVar)        x