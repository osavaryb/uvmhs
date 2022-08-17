module UVMHS.Tests.Substitution (g__TESTS__UVMHS__Tests__Substitution) where

import UVMHS.Core

import UVMHS.Lib.Rand
import UVMHS.Lib.Substitution
import UVMHS.Lib.Testing
import UVMHS.Lib.Variables

import UVMHS.Lang.ULCD

-- basic --

𝔱 "subst:id" [| subst null [ulcd| λ → 0   |] |] [| Some [ulcd| λ → 0   |] |]
𝔱 "subst:id" [| subst null [ulcd| λ → 1   |] |] [| Some [ulcd| λ → 1   |] |]
𝔱 "subst:id" [| subst null [ulcd| λ → 2   |] |] [| Some [ulcd| λ → 2   |] |]
𝔱 "subst:id" [| subst null [ulcd| λ → 0 2 |] |] [| Some [ulcd| λ → 0 2 |] |]

𝔱 "subst:intro" [| subst (𝓈dintro 1) [ulcd| λ → 0   |] |] [| Some [ulcd| λ → 0   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 1) [ulcd| λ → 1   |] |] [| Some [ulcd| λ → 2   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 1) [ulcd| λ → 2   |] |] [| Some [ulcd| λ → 3   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 1) [ulcd| λ → 0 2 |] |] [| Some [ulcd| λ → 0 3 |] |]

𝔱 "subst:intro" [| subst (𝓈dintro 2) [ulcd| λ → 0   |] |] [| Some [ulcd| λ → 0   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 2) [ulcd| λ → 1   |] |] [| Some [ulcd| λ → 3   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 2) [ulcd| λ → 2   |] |] [| Some [ulcd| λ → 4   |] |]
𝔱 "subst:intro" [| subst (𝓈dintro 2) [ulcd| λ → 0 2 |] |] [| Some [ulcd| λ → 0 4 |] |]

𝔱 "subst:bind" [| subst (𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0     |] |]
𝔱 "subst:bind" [| subst (𝓈dbind [ulcd| λ → 1 |]) [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0     |] |]
𝔱 "subst:bind" [| subst (𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 1 |] |] [| Some [ulcd| λ → λ → 0 |] |]
𝔱 "subst:bind" [| subst (𝓈dbind [ulcd| λ → 1 |]) [ulcd| λ → 1 |] |] [| Some [ulcd| λ → λ → 2 |] |]

𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 0 |] |] 
                 [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 1 |]) [ulcd| λ → 0 |] |] 
                 [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 1 |] |] 
                 [| Some [ulcd| λ → 1 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 1 |]) [ulcd| λ → 1 |] |] 
                 [| Some [ulcd| λ → 1 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 2 |]) [ulcd| λ → 0 |] |] 
                 [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 2 |]) [ulcd| λ → 1 |] |] 
                 [| Some [ulcd| λ → 1 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 1 |]) [ulcd| λ → 2 |] |] 
                 [| Some [ulcd| λ → λ → 3 |] |]
𝔱 "subst:shift" [| subst (𝓈dshift 1 $ 𝓈dbind [ulcd| λ → 2 |]) [ulcd| λ → 2 |] |] 
                 [| Some [ulcd| λ → λ → 4 |] |]

-- append --

𝔱 "subst:⧺" [| subst null            [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:⧺" [| subst (null ⧺ null)   [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:⧺" [| subst (𝓈dshift 1 null) [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:⧺" [| subst (𝓈dshift 2 null) [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]

𝔱 "subst:⧺" [| subst null          [ulcd| λ → 1 |] |] [| Some [ulcd| λ → 1 |] |]
𝔱 "subst:⧺" [| subst (null ⧺ null) [ulcd| λ → 1 |] |] [| Some [ulcd| λ → 1 |] |]

𝔱 "subst:⧺" [| subst (𝓈dintro 1)               [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]
𝔱 "subst:⧺" [| subst (null ⧺ 𝓈dintro 1 ⧺ null) [ulcd| λ → 0 |] |] [| Some [ulcd| λ → 0 |] |]

𝔱 "subst:⧺" [| subst (𝓈dintro 1)               [ulcd| λ → 1 |] |] [| Some [ulcd| λ → 2 |] |]
𝔱 "subst:⧺" [| subst (null ⧺ 𝓈dintro 1 ⧺ null) [ulcd| λ → 1 |] |] [| Some [ulcd| λ → 2 |] |]

𝔱 "subst:⧺" [| subst (𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 1 |] |] 
            [| Some [ulcd| λ → λ → 0 |] |]
𝔱 "subst:⧺" [| subst (null ⧺ 𝓈dbind [ulcd| λ → 0 |] ⧺ null) [ulcd| λ → 1 |] |] 
            [| Some [ulcd| λ → λ → 0 |] |]

𝔱 "subst:⧺" [| subst (𝓈dintro 2) [ulcd| λ → 1 |] |]            [| Some [ulcd| λ → 3 |] |]
𝔱 "subst:⧺" [| subst (𝓈dintro 1 ⧺ 𝓈dintro 1) [ulcd| λ → 1 |] |] [| Some [ulcd| λ → 3 |] |]

𝔱 "subst:⧺" [| subst (𝓈dbind [ulcd| λ → 0 |]) [ulcd| λ → 1 |] |] 
            [| Some [ulcd| λ → λ → 0 |] |]
𝔱 "subst:⧺" [| subst (𝓈dshift 1 (𝓈dbind [ulcd| λ → 0 |]) ⧺ 𝓈dintro 1) [ulcd| λ → 1 |] |] 
            [| Some [ulcd| λ → λ → 0 |] |]

𝔱 "subst:⧺" [| subst (𝓈dintro 1 ⧺ 𝓈dbind [ulcd| 1 |]) [ulcd| 0 (λ → 2) |] |] 
            [| Some [ulcd| 2 (λ → 2) |] |]
𝔱 "subst:⧺" [| subst (𝓈dshift 1 (𝓈dbind [ulcd| 1 |]) ⧺ 𝓈dintro 1) [ulcd| 0 (λ → 2) |] |] 
            [| Some [ulcd| 2 (λ → 2) |] |]

𝔱 "subst:⧺" [| subst (𝓈dintro 1) *$ subst (𝓈dshift 1 null) [ulcd| 0 |] |]
            [| subst (𝓈dintro 1 ⧺ 𝓈dshift 1 null) [ulcd| 0 |] |]

𝔱 "subst:⧺" [| subst (𝓈dbind [ulcd| 1 |]) *$ subst (𝓈dshift 1 (𝓈dintro 1)) [ulcd| 0 |] |]
            [| subst (𝓈dbind [ulcd| 1 |] ⧺ 𝓈dshift 1 (𝓈dintro 1)) [ulcd| 0 |] |]

𝔱 "subst:⧺" [| subst (𝓈dshift 1 (𝓈dbind [ulcd| 1 |])) *$ subst (𝓈dshift 1 null) [ulcd| 1 |] |]
            [| subst (𝓈dshift 1 (𝓈dbind [ulcd| 1 |]) ⧺ 𝓈dshift 1 null) [ulcd| 1 |] |]

𝔱 "subst:⧺" [| subst (𝓈dshift 1 (𝓈dbind [ulcd| 3 |]) ⧺ null) [ulcd| 0 |] |]
            [| subst (𝓈dshift 1 (𝓈dbind [ulcd| 3 |])) [ulcd| 0 |] |]

-- de bruijn conversion --


𝔱 "subst:todbr" [| todbr [ulcd| λ x → x             |] |] [| Some [ulcd| λ x → 0             |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ x → 0             |] |] [| Some [ulcd| λ x → 0             |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ x → x 0           |] |] [| Some [ulcd| λ x → 0 0           |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ x → x 0 1         |] |] [| Some [ulcd| λ x → 0 0 1         |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ x → x 0 y         |] |] [| Some [ulcd| λ x → 0 0 y         |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ x → x 0 1 y       |] |] [| Some [ulcd| λ x → 0 0 1 y       |] |]

𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → x       |] |] [| Some [ulcd| λ y → λ x → 0       |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → 0       |] |] [| Some [ulcd| λ y → λ x → 0       |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → x 0     |] |] [| Some [ulcd| λ y → λ x → 0 0     |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → x 0 1   |] |] [| Some [ulcd| λ y → λ x → 0 0 1   |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → x 0 y   |] |] [| Some [ulcd| λ y → λ x → 0 0 1   |] |]
𝔱 "subst:todbr" [| todbr [ulcd| λ y → λ x → x 0 1 y |] |] [| Some [ulcd| λ y → λ x → 0 0 1 1 |] |]

𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → x             |] |] [| Some [ulcd| λ x → x             |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → 0             |] |] [| Some [ulcd| λ x → x             |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → x 0           |] |] [| Some [ulcd| λ x → x x           |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → x 0 1         |] |] [| Some [ulcd| λ x → x x 1         |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → x 0 y         |] |] [| Some [ulcd| λ x → x x y         |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ x → x 0 1 y       |] |] [| Some [ulcd| λ x → x x 1 y       |] |]

𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → x       |] |] [| Some [ulcd| λ y → λ x → x       |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → 0       |] |] [| Some [ulcd| λ y → λ x → x       |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → x 0     |] |] [| Some [ulcd| λ y → λ x → x x     |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → x 0 1   |] |] [| Some [ulcd| λ y → λ x → x x y   |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → x 0 y   |] |] [| Some [ulcd| λ y → λ x → x x y   |] |]
𝔱 "subst:tonmd" [| tonmd [ulcd| λ y → λ x → x 0 1 y |] |] [| Some [ulcd| λ y → λ x → x x y y |] |]

𝔱 "subst:freev" [| freev [ulcd| λ x → 0           |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → x           |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → λ y → 1 0   |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → λ y → x 0   |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → λ y → 1 y   |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → λ y → x y   |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → 0) 0 |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → y) 0 |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → 0) x |] |] [| FreeVars null null |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → y) x |] |] [| FreeVars null null |]

𝔱 "subst:freev" [| freev [ulcd| 0         |] |]         [| FreeVars null $ (():*None) ↦ pow [0]   |]
𝔱 "subst:freev" [| freev [ulcd| 0 1       |] |]         [| FreeVars null $ (():*None) ↦ pow [0,1] |]
𝔱 "subst:freev" [| freev [ulcd| λ x → 0 1 |] |]         [| FreeVars null $ (():*None) ↦ pow [0]   |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → 2) 0 |] |] [| FreeVars null $ (():*None) ↦ pow [0]   |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → 1) 1 |] |] [| FreeVars null $ (():*None) ↦ pow [0]   |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → 2) 1 |] |] [| FreeVars null $ (():*None) ↦ pow [0]   |]

𝔱 "subst:freev" [| freev [ulcd| x |] |] 
                [| FreeVars null $ dict 
                     [ (():*Some (var "x")) ↦ pow [0]
                     ] 
                |]
𝔱 "subst:freev" [| freev [ulcd| x y |] |] 
                [| FreeVars null $ dict
                     [ (():*Some (var "x")) ↦ pow [0] 
                     , (():*Some (var "y")) ↦ pow [0] 
                     ]
                |]
𝔱 "subst:freev" [| freev [ulcd| λ x → y |] |] 
                [| FreeVars null $ dict
                     [ (():*Some (var "y")) ↦ pow [0] 
                     ]
                |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → x) y |] |] 
                [| FreeVars null $ dict
                     [ (():*Some (var "y")) ↦ pow [0] 
                     ]
                |]
𝔱 "subst:freev" [| freev [ulcd| λ x → (λ y → x) x y |] |] 
                [| FreeVars null $ dict
                     [ (():*Some (var "y")) ↦ pow [0] 
                     ]
                |]

-- fuzzing --

𝔣 "zzz:subst:hom:refl" 100 
  [| do e ← randSml @ULCDExpRaw
        return e
  |]
  [| \ e → subst null e ≡ Some e |]

𝔣 "zzz:subst:hom:⧺" 100
  [| do 𝓈₁ ← randSml @(Subst () ULCDExpRaw)
        𝓈₂ ← randSml @(Subst () ULCDExpRaw)
        e ← randSml @ULCDExpRaw
        return $ 𝓈₁ :* 𝓈₂ :* e
  |]
  [| \ (𝓈₁ :* 𝓈₂ :* e) → subst (𝓈₁ ⧺ 𝓈₂) e ≡ (subst 𝓈₁ *$ subst 𝓈₂ e) |]

𝔣 "zzz:subst:lunit:⧺" 100 
  [| do 𝓈 ← randSml @(Subst () ULCDExpRaw)
        e ← randSml @ULCDExpRaw
        return $ 𝓈 :* e
  |]
  [| \ (𝓈 :* e) → subst (null ⧺ 𝓈) e ≡ subst 𝓈 e |]

𝔣 "zzz:subst:runit:⧺" 100 
  [| do 𝓈 ← randSml @(Subst () ULCDExpRaw)
        e ← randSml @ULCDExpRaw
        return $ 𝓈 :* e
  |]
  [| \ (𝓈 :* e) → subst (𝓈 ⧺ null) e ≡ subst 𝓈 e |]

𝔣 "zzz:subst:trans:⧺" 100 
  [| do 𝓈₁ ← randSml @(Subst () ULCDExpRaw)
        𝓈₂ ← randSml @(Subst () ULCDExpRaw)
        𝓈₃ ← randSml @(Subst () ULCDExpRaw)
        e ← randSml @ULCDExpRaw
        return $ 𝓈₁ :* 𝓈₂ :* 𝓈₃ :* e
  |]
  [| \ (𝓈₁ :* 𝓈₂ :* 𝓈₃ :* e) → subst ((𝓈₁ ⧺ 𝓈₂) ⧺ 𝓈₃) e ≡ subst (𝓈₁ ⧺ (𝓈₂ ⧺ 𝓈₃)) e |]

𝔣 "zzz:subst:unit:shift" 100
  [| do i ← randSml @ℕ64
        e ← randSml @ULCDExpRaw
        return $ i :* e
  |]
  [| \ (i :* e) → subst (𝓈dshift i null) e ≡ Some e |]

𝔣 "zzz:subst:unit:bind∘intro" 100
  [| do e₁ ← randSml @ULCDExpRaw
        e₂ ← randSml @ULCDExpRaw
        return $ e₁ :* e₂
  |]
  [| \ (e₁ :* e₂) → (subst (𝓈dbind e₁) *$ subst (𝓈dintro 1) e₂) ≡ Some e₂ |]

𝔣 "zzz:subst:commute:intro∘bind" 100
  [| do e₁ ← randSml @ULCDExpRaw
        e₂ ← randSml @ULCDExpRaw
        return $ e₁ :* e₂
  |]
  [| \ (e₁ :* e₂) → 
         (subst (𝓈dintro 1) *$ subst (𝓈dbind e₁) e₂)
         ≡ 
         (subst (𝓈dshift 1 $ 𝓈dbind e₁) *$ subst (𝓈dintro 1) e₂)
  |]

𝔣 "zzz:subst:dist:shift/⧺" 100 
  [| do n  ← randSml @ℕ64
        𝓈₁ ← randSml @(Subst () ULCDExpRaw)
        𝓈₂ ← randSml @(Subst () ULCDExpRaw)
        e  ← randSml @ULCDExpRaw
        return $ n :* 𝓈₁ :* 𝓈₂ :* e
  |]
  [| \ (n :* 𝓈₁ :* 𝓈₂ :* e) → subst (𝓈dshift n (𝓈₁ ⧺ 𝓈₂)) e ≡ subst (𝓈dshift n 𝓈₁ ⧺ 𝓈dshift n 𝓈₂) e |]

𝔣 "zzz:subst:todbr:idemp" 100
  [| do randSml @ULCDExpRaw |]
  [| \ e → todbr e ≡ (todbr *$ todbr e)  |]

𝔣 "zzz:subst:todbr:∘tonmd" 100
  [| do randSml @ULCDExpRaw |]
  [| \ e → todbr e ≡ (todbr *$ tonmd e)  |]

𝔣 "zzz:subst:tonmd:idemp" 100
  [| do randSml @ULCDExpRaw |]
  [| \ e → tonmd e ≡ (tonmd *$ tonmd e)  |]

𝔣 "zzz:subst:tonmd:∘todbr" 100
  [| do randSml @ULCDExpRaw |]
  [| \ e → tonmd e ≡ (tonmd *$ todbr e)  |]

buildTests