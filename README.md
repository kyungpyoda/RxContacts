# RxContacts
Cloning 'Contacts App for iPhone' with RxSwift

## Branches
0. [**`master`**](../../tree/master)
  - 최종본, `feat/withReactorKitCNContact` 브랜치와 같음
1. [`feat/withoutReactorKitCNContact`](../../tree/feat/withoutReactorKitCNContact)
  - 더미 데이터로 기본 기능만 구현 (RxSwift, RxCocoa, RxDataSources 이용)
  - [Pull request](https://github.com/kyungpyoda/RxContacts/pull/1)
2. [`feat/MVVM`](../../tree/feat/MVVM)
  - MVVM 적용 (based on `feat/withoutReactorKitCNContact`)
  - ReactorKit의 흐름 학습에 도움이 될 것 같아서 MVVM도 같이 해봤음
  - [Pull request](https://github.com/kyungpyoda/RxContacts/pull/3)
3. [`feat/withReactorKit`](../../tree/feat/withReactorKit)
  - ReactorKit 적용 (based on `feat/withoutReactorKitCNContact`)
  - RxSwift, RxCocoa, RxDataSources 이용
  - [Pull request](https://github.com/kyungpyoda/RxContacts/pull/2)
4. [`feat/withReactorKitCNContact`](../../tree/feat/withoutReactorKitCNContact)
  - Contacts Framework 적용 (based on `feat/withReactorKit`)
  - > [Contacts | Apple Developer Documentation](https://developer.apple.com/documentation/contacts)
  - [Pull request](https://github.com/kyungpyoda/RxContacts/pull/4)
