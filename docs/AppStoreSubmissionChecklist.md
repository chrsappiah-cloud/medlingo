# App Store Submission Checklist (ARC Shield Spec Guard)

Complete before every App Store Connect submission.

## Device verification

- [ ] Clean install on a current iPhone (physical device)
- [ ] Launch works offline (airplane mode → open app → no crash)
- [ ] No blank or endless loading on Learn, Practice, Account
- [ ] 10-minute exploratory pass on physical device completed

## Permissions

- [ ] Microphone / camera denial paths degrade gracefully (if used)
- [ ] Settings recovery copy visible when permission denied

## Auth & account

- [ ] Sign-in path works (or guest/demo path documented for reviewers)
- [ ] Sign-out works from Account
- [ ] Account deletion or support path works if required

## Subscriptions (StoreKit)

- [ ] Subscription plans load or show clear error (not silent failure)
- [ ] Upgrade button shows loading state during purchase
- [ ] Restore Purchases completes without crash
- [ ] Previous rejection regression tests pass (see `docs/RegressionLedger.md`)

## Navigation & stability

- [ ] All main tabs reachable (Learn, Practice, Collection, Sessions, Progress, Account)
- [ ] Deep links do not dead-end (if applicable)
- [ ] App survives background → foreground
- [ ] No blocker/critical defects open

## Automated gates

- [ ] PR lane: unit tests + smoke UI pass
- [ ] Main lane: unit + integration + UI smoke pass
- [ ] Release lane: full UI review flows + regression suite pass

## Build metadata

- [ ] Version and build number incremented
- [ ] TestFlight build processed
- [ ] `AppStoreSubmissionForm.md` fields updated
- [ ] Review notes updated in `AppStoreReviewNotes.md`

**Verified by:** _______________  
**Build number:** _______________  
**Date:** _______________
