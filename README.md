# 📨 Twitter

## 📖 목차
1. [소개](#-소개)
2. [기능 및 구현사항](#-기능-및-구현사항)
3. [실행 화면](#-실행-화면)
4. [개발과정의 고민 및 학습한 점](#-개발과정의-고민-및-학습한-점)
5. [프로젝트 구조](#-프로젝트-구조)

</br>

## 🍀 소개
Twitter 앱의 기능을 실제로 구현해 보고 Firebase를 통해 전체 데이터를 관리하였습니다.

</br>

## ✨ 기능 및 구현사항
![Mockup - Twitter](https://github.com/user-attachments/assets/b13743a7-5277-4e9c-ae2b-c456abf94549)

**0. 아키텍쳐 및 주요기술** 
  - MVVM 아키텍쳐를 활용해 View와 ViewModel의 역할을 구분합니다.
  - Firebase를 활용한 서버통신 및 인증(로그인/회원가입)을 지원합니다.

**1. 로그인 및 회원가입** (이미지 1)
  - **FirebaseAuth 를 활용해 로그인 및 회원가입 구현하였습니다.**
  - FirebaseAuth 내부에선 로그인시 인증정보를 Keychain에 저장합니다.
  - 메인뷰에서 Keychain 저장 정보 확인 후 인증정보가 있으면 메인뷰를 표시합니다.
  - 인증정보가 없으면 로그인 화면을 표시합니다.

**2. 메인탭(피드)** (이미지 2 ∙ 3 ∙ 4)
  - **사용자의 모든 트윗을 불러와 피드에(컬렉션뷰) 표시합니다.**
  - 피드는 refreshControl을 이용해 새로고침 할 수 있습니다.
  - 다른 사람의 트윗에 댓글을 남길 수 있습니다.
  - 프로필 뷰에서는 사용자의 프로필 설정, 작성한 트윗 표시, 팔로우 기능 등을 사용할 수 있습니다.
  - 트윗 상세 뷰에는 좋아요 수 및 작성된 댓글이 표시됩니다.

**3. 트윗 업로드 뷰** (이미지 5)
  - **트윗 및 댓글을 업로드합니다.**
  - 뷰의 매개변수로 열거형을 받아 `tweet`과 `reply` 여부에 따라 하나의 뷰에서 다른 UI와 메서드를 사용합니다.

**4. 유저 탐색 탭** (이미지 6)
  - **트위터를 사용중인 모든 유저를 검색할 수 있습니다.**
  - `UISearchController` 및 `UISearchResultsUpdating`을 사용해 구현하였습니다.

**5. 알림 탭** (이미지 7)
  - **나를 팔로우하거나 트윗에 좋아요 및 댓글을 남길 시 알림이 전달됩니다.**
  - 누군가를 팔로우하거나, 트윗에 좋아요 및 댓글을 남길 시 데이터베이스의 notifications 테이블에 이를 저장합니다.
  - Firebase의 `.observe(.childAdded)` 메서드를 사용하여 이를 실시간으로 감지 후 사용자에게 알림을 표시합니다.

</br>

## 💻 실행 화면 
|로그인 ∙ 회원가입 뷰|메인 탭|트윗 업로드 뷰|유저 탐색 탭|알림 탭|
|-|-|-|-|-|
|<img width="180" src="https://github.com/user-attachments/assets/98efcbb4-c759-4c04-b8fd-51a219ce6de5">|<img width="180" src="https://github.com/user-attachments/assets/179a7f50-8951-4144-9107-87fba667113c">|<img width="180" src="https://github.com/user-attachments/assets/1aba7385-0c9d-4d87-93cb-def92b3acd55">|<img width="180" src="https://github.com/user-attachments/assets/84c4c777-e58d-4ac5-8ea9-252a552a8cf4">|<img width="180" src="https://github.com/user-attachments/assets/80037d27-989c-404d-abf8-428263a102d6">|


</br>

## 🤔 개발과정의 고민 및 학습한 점
<details>
<summary><strong style="font-size: 1.2em;">순환참조 시 발생하는 메모리 누수 관리</strong></summary>
<br>

**커스텀 델리게이트 패턴을 사용하면서 순환참조가 일어나는 상황이 발생하였습니다.**

`ProfileController` 클래스가 참조하는 컬렉션뷰의 헤더로 `ProfileHeader`의 인스턴스가 할당되면서 참조가 발생하였습니다. 이어서 `ProfileHeader`의 delegate 로 `ProfileController(self)`가 할당되면서 다시 참조가 발생합니다. 이는 서로 강하게 참조하고 있기 때문에 순환참조가 발생하는 상황이며 이것이 메모리 누수를 야기하였습니다.

```swift
// ProfileController
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
}
// ProfileHeader
class ProfileHeader: UICollectionReusableView {
    var delegate: ProfileHeaderDelegate?
    // weak var delegate: ProfileHeaderDelegate?
    // ... [후략] ...
}
```

**메모리 누수를 실험을 통해 그래프로 확인하기**

순환참조를 방지하는 것은 `weak var delegate`와 같이 약한 참조로 변경하면 해결할 수 있습니다. 하지만 실제로 메모리 누수가 발생할 경우 메모리 그래프가 어떻게 변하는지 확인해 보았습니다. 

`weak`를 써준 경우와 안 써준 경우 각각 열 번씩 `ProfileController` 뷰를 열고 닫은 후 메모리 사용량을 비교해 본 결과입니다. `weak`를 써주지 않은 경우 반대의 경우보다 4MB의 메모리가 더 사용되고 있음을 확인할 수 있습니다.

커스텀 델리게이트 패턴을 사용하는 경우와 클로저가 `self`를 캡처하는 경우에 기계적으로 `weak`를 써줄 때가 많았지만, 메모리 누수 상황을 실험하면서 약한 참조의 중요성을 확인할 수 있었습니다.
    
<img width="250" src="https://github.com/user-attachments/assets/a5d2ba8a-83c8-48c1-b31f-45242c71791a">

<img width="250" src="https://github.com/user-attachments/assets/9de15325-4cb6-4c07-b0f3-af7addf41e61">
</details>

<details>
<summary><strong style="font-size: 1.2em;">커스텀 액션시트 만들기</strong></summary>
    
<br>
    
<img width="300" src="https://github.com/user-attachments/assets/397dfdf3-82e0-4d83-9b82-66611dad14a3">

<br>
<br>

**UIAlertController와 최대한 유사하게 구현하기**

`UIAlertController`와 같이 네비게이션바나 탭바 위를 덮어야 하고, 뒷배경이 흐려져야 합니다. 기존의 `ViewController`를 `present`하거나, `navigationController`에서 `pushViewController`하는 방식으로는 구현하기 어려운 문제였습니다.

**뷰의 계층구조**

배경의 뷰를 그대로 살리면서 앞단에 액션시트를 추가하려면 뷰 계층구조의 루트 컨테이너인 UIWindow에 뷰를 추가해야합니다. 뷰 계층구조는 넓게 보면 UIScreen - UIWindowScene - UIWindow로 구성되어 있는데, UIWindowScene을 통해서 UIWindow에 접근할 수 있습니다. `isKeyWindow` 속성은 현재 사용자 입력을 받는 UIWindow를 의미하기에 해당 속성이 true인 UIWindow에 접근하여 원하는 작업을 수행할 수 있습니다.

```swift
// ActionSheetLauncher
func show() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
    
    window.addSubview(blackView)
    blackView.frame = window.frame
    
    window.addSubview(tableView)
    tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: actionSheetHeight)
    
    UIView.animate(withDuration: 0.5) {
        self.blackView.alpha = 1
        self.tableView.frame.origin.y -= self.actionSheetHeight
    }
}
```

</details>

<details>
<summary><strong style="font-size: 1.2em;">학습한 점</strong></summary>

## 커스텀 델리게이트 패턴

### 뷰 컨트롤러간의 소통을 통해 이벤트 처리를 할 때, 커스텀 델리게이트 패턴을 사용합니다.

```swift
// FeedController
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        return cell
    }
}
extension FeedController: TweetCellDelegate {
    func handleProfileImageTapped(_ cell: TweetCell) {
        let vc = ProfileController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// TweetCell
protocol TweetCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCell)
}
class TweetCell : UICollectionViewCell {
    weak var delegate: TweetCellDelegate?
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
}
```

## Enum을 활용해 재사용 가능한 코드를 작성합니다.

<img width="200" src="https://github.com/user-attachments/assets/0cca1e62-055c-4fc7-926a-01b0a95c5a33">
<img width="200" src="https://github.com/user-attachments/assets/09481c66-ed93-48ab-a6ea-39d41ed02fc5">

위 그림과 같이 트윗을 작성하는 뷰와 다른 사람의 트윗에 대해 댓글을 작성한 뷰는 매우 유사합니다. 뷰를 따로 만들지 않고, 하나의 뷰에 매개변수로 `tweet`과 `reply` 케이스를 가지는 Enum을 전달하여 재사용 가능한 뷰를 구현하였습니다. 

`reply` 케이스는 연관값을 매개변수로 받아 어떤 tweet에 대한 reply인지도 구분하도록 하였습니다. 작성된 글을 업로드하는 메서드에서도 케이스 별로 다른 코드를 작성해 주었습니다.

```swift
// UploadTweetViewModel
enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

class UploadTweetViewModel {
    let actionButtonTitle: String
    init(config: UploadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
        case .reply(let tweet):
            actionButtonTitle = "Reply"
        }
    }
}

// uploadTweetController
class UploadTweetController: UIViewController {
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    @objc func handleUploadTweet() {
        TweetService.shared.uploadTweet(caption: caption, type: config) 
    }
}

// TweetService
struct TweetService {
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping ( Error?, DatabaseReference) -> Void) {       
        switch type {
        case .tweet:
            REF_TWEETS.childByAutoId().updateChildValues(values) { err, ref in
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId().updateChildValues(values, withCompletionBlock: completion)
        }
    }
}
```

</details>

</br>

## 🗂 프로젝트 구조

~~~
📦 TwitterTutorial
 ┣ 📂App
 ┣ 📂Network
 ┣ 📂Model
 ┣ 📂Presentation
 ┃ ┣ 📂AuthenticationScene
 ┃ ┣ 📂MainTabBarScene
 ┃ ┣ 📂FeedScene
 ┃ ┣ 📂UploadTweetScene
 ┃ ┣ 📂ProfileScene
 ┃ ┣ 📂TweetScene
 ┃ ┣ 📂ExploreScene
 ┃ ┣ 📂NotificationScene
 ┃ ┣ 📂ConversationScene
 ┃ ┗ 📂Common
 ┗ 📂Utility
~~~

### 📚 Architecture ∙ Framework ∙ Library

| Category| Name | Tag |
| ---| --- | --- |
| Architecture| MVVM |  |
| Framework| UIKit | UI |
|Library | Firebase | DB ∙ Authentication |
| | SnapKit | Layout |
| | Kingfisher | Image Caching |

</br>
