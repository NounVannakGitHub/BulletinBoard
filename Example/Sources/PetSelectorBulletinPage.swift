/**
 *  Bulletin
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import Bulletin

/**
 * An item that displays a choice with two buttons.
 *
 * This item demonstrates how to create a bulletin item with a custom interface.
 */

class PetSelectorBulletinPage: BulletinItem {

    /**
     * The object managing the item. Required by the `BulletinItem` protocol.
     *
     * You can use it to switch to the previous/next item or dismiss the bulletin.
     *
     * Always check if it is nil, as the manager will unset this value when the current item changes.
     */

    weak var manager: BulletinManager?

    /**
     * Whether the item can be dismissed. If you set this value to `true`, the user will be able
     * to dimiss the bulletin by tapping outside the card.
     *
     * You should set it to true for optional items or if it is the last in a configuration sequence.
     */

    var isDismissable: Bool = false

    /**
     * An object that creates standard inteface components.
     *
     * You should use it to create views whenever possible. It also allows to customize the tint color
     * of the buttons.
     */

    let interfaceFactory = BulletinInterfaceFactory()


    // MARK: - Interface Elements

    private var catButtonContainer: ContainerView<UIButton>!
    private var dogButtonContainer: ContainerView<UIButton>!
    private var saveButtonContainer: ContainerView<HighlightButton>!

    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()
    private var successFeedbackGenerator = SuccessFeedbackGenerator()

    // MARK: - BulletinItem

    /**
     * Called by the manager when the item is about to be removed from the bulletin.
     *
     * Use this function as an opportunity to do any clean up or remove tap gesture recognizers /
     * button targets from your views to avoid retain cycles.
     */

    func tearDown() {
        catButtonContainer?.contentView.removeTarget(self, action: nil, for: .touchUpInside)
        dogButtonContainer?.contentView.removeTarget(self, action: nil, for: .touchUpInside)
        saveButtonContainer?.contentView.removeTarget(self, action: nil, for: .touchUpInside)
    }

    /**
     * Called by the manager to build the view hierachy of the bulletin.
     *
     * We need to return the view in the order we want them displayed. You should use a
     * `BulletinInterfaceFactory` to generate standard views, such as title labels and buttons.
     */

    func makeArrangedSubviews() -> [UIView] {

        var arrangedSubviews = [UIView]()
        let favoriteTabIndex = BulletinDataSource.favoriteTabIndex

        // Title Label

        let titleLabel = interfaceFactory.makeTitleLabel()
        titleLabel.text = "Choose your Favorite"
        arrangedSubviews.append(titleLabel)

        // Description Label

        let isDescriptionCompact = false // The text is short, so we don't need to display it with a smaller font
        let descriptionLabel = interfaceFactory.makeDescriptionLabel(isCompact: isDescriptionCompact)
        descriptionLabel.text = "Your favorite pets will appear when you open the app."
        arrangedSubviews.append(descriptionLabel)

        // Pets Stack

        // We add choice cells to a group stack because they need less spacing
        let petsStack = interfaceFactory.makeGroupStack(spacing: 16)
        arrangedSubviews.append(petsStack)

        // Cat Button

        let catButtonContainer = createChoiceCell(title: "🐱 Cats", isSelected: favoriteTabIndex == 0)
        catButtonContainer.contentView.addTarget(self, action: #selector(catButtonTapped), for: .touchUpInside)
        petsStack.addArrangedSubview(catButtonContainer)

        self.catButtonContainer = catButtonContainer

        // Dog Button

        let dogButtonContainer = createChoiceCell(title: "🐶 Dogs", isSelected: favoriteTabIndex == 1)
        dogButtonContainer.contentView.addTarget(self, action: #selector(dogButtonTapped), for: .touchUpInside)
        petsStack.addArrangedSubview(dogButtonContainer)

        self.dogButtonContainer = dogButtonContainer

        // Save Button

        let saveButtonContainer = interfaceFactory.makeActionButton(title: "Save")
        saveButtonContainer.contentView.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        arrangedSubviews.append(saveButtonContainer)

        return arrangedSubviews

    }

    // MARK: - Custom Views

    /**
     * Creates a custom choice cell.
     */

    func createChoiceCell(title: String, isSelected: Bool) -> ContainerView<UIButton> {

        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center

        let buttonContainer = ContainerView<UIButton>(button)
        buttonContainer.layer.cornerRadius = 12
        buttonContainer.layer.borderWidth = 2

        buttonContainer.heightAnchor.constraint(equalToConstant: 55).isActive = true

        let buttonColor = isSelected ? interfaceFactory.tintColor : .lightGray
        buttonContainer.layer.borderColor = buttonColor.cgColor
        buttonContainer.contentView.setTitleColor(buttonColor, for: .normal)
        buttonContainer.layer.borderColor = buttonColor.cgColor

        return buttonContainer

    }

    // MARK: - Touch Events

    /// Called when the cat button is tapped.
    @objc func catButtonTapped() {

        // Play haptic feedback

        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()

        // Update UI

        let catButtonColor = interfaceFactory.tintColor
        catButtonContainer?.layer.borderColor = catButtonColor.cgColor
        catButtonContainer?.contentView.setTitleColor(catButtonColor, for: .normal)

        let dogButtonColor = UIColor.lightGray
        dogButtonContainer?.layer.borderColor = dogButtonColor.cgColor
        dogButtonContainer?.contentView.setTitleColor(dogButtonColor, for: .normal)

        // Send a notification to inform observers of the change

        NotificationCenter.default.post(name: .FavoriteTabIndexDidChange,
                                        object: self,
                                        userInfo: ["Index": 0])

    }

    /// Called when the dog button is tapped.
    @objc func dogButtonTapped() {

        // Play haptic feedback

        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()

        // Update UI

        let catButtonColor = UIColor.lightGray
        catButtonContainer?.layer.borderColor = catButtonColor.cgColor
        catButtonContainer?.contentView.setTitleColor(catButtonColor, for: .normal)

        let dogButtonColor = interfaceFactory.tintColor
        dogButtonContainer?.layer.borderColor = dogButtonColor.cgColor
        dogButtonContainer?.contentView.setTitleColor(dogButtonColor, for: .normal)

        // Send a notification to inform observers of the change

        NotificationCenter.default.post(name: .FavoriteTabIndexDidChange,
                                        object: self,
                                        userInfo: ["Index": 1])

    }

    /// Called when the save button is tapped.
    @objc func saveButtonTapped() {

        // Play haptic feedback

        successFeedbackGenerator.prepare()
        successFeedbackGenerator.success()

        // Ask the manager to present the next item.
        manager?.displayNextItem()

    }

}
