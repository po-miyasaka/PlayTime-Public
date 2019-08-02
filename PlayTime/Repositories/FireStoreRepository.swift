//
//  FireStoreRepository.swift
//
//
//  Created by kazutoshi miyasaka on 2019/02/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

protocol FireStoreRepositoryOutput {
}

protocol FireStoreRepositoryInput {
    func backup(entity: BackupEntity, uuid: String)
    func fetchMetaData()
    func restore(entity: BackupEntity)
    func resetData()
}

protocol FireStoreRepositoryProtocol {
    var inputs: FireStoreRepositoryInput { get }
    var outputs: FireStoreRepositoryOutput { get }
}

class FireStoreRepository: FireStoreRepositoryProtocol {
    var inputs: FireStoreRepositoryInput { return self }
    var outputs: FireStoreRepositoryOutput { return self }

    let db = Firestore.firestore()

    var uidQuery: DocumentReference { return db.collection("users").document(uid) }
    var questListQuery: CollectionReference { return uidQuery.collection("questsList") }
    let uid: UID
    let actionCreator: ActionCreatorProtocol

    init(uid: UID, actionCreator: ActionCreatorProtocol = ActionCreator.default) {
        self.uid = uid
        self.actionCreator = actionCreator
    }
}

extension FireStoreRepository: FireStoreRepositoryOutput {

}

extension FireStoreRepository: FireStoreRepositoryInput {
    func resetData() {
        self.uidQuery.delete()
        self.questListQuery.getDocuments { result, _ in
            let references = result?.documents.compactMap { $0.reference } ?? []
            references.forEach {
                $0.delete()
            }
        }
    }

    func fetchMetaData() {
        self.uidQuery.addSnapshotListener(includeMetadataChanges: false) {[weak self] snapShot, _ in

            guard
                let backupMetaData = QuestsBackupData(from: snapShot)
                else {
                    self?.actionCreator.backupUserStatus(status: BackupEntity.UserStatus.neverHosted )
                    return
            }

            self?.actionCreator.fetchedHostedMetaData(data: backupMetaData)

        }
    }

    func backup(entity: BackupEntity, uuid: String) {
        if case .failure(let e) = entity.backupVaridate() {
            self.actionCreator.backupError(error: e)
            return
        }

        guard let meta = entity.varidatedQuestsData?.getMeta, let datas = entity.varidatedQuestsData?.data else {
            self.actionCreator.backupError(error: BackupError.localData)
            return
        }

        switch entity.status {
        case .neverHosted:
            batch(references: [], datas: datas, meta: meta, uuid: uuid)
        case .hosted:
            self.questListQuery.getDocuments { [weak self] result, _ in
                let references = result?.documents.compactMap { $0.reference } ?? []
                self?.batch(references: references, datas: datas, meta: meta, uuid: uuid)
            }
        case .undefined:
            self.actionCreator.backupError(error: BackupError.localData)

        case .notLogined:
            self.actionCreator.backupError(error: .notLogined)

        case .restored:
            break
        case .logoutNow:
            self.actionCreator.backupError(error: .logoutNow)
        }

    }

    func batch(references: [DocumentReference], datas: [Data], meta: [String: Any], uuid: String) {
        references.forEach {
            $0.delete()
        }
        self.uidQuery.setData(["uuid": [uuid + self.uid]], merge: false)
        self.uidQuery.setData(["metadata": meta], merge: false)
        datas.forEach {
            self.questListQuery.document().setData(["data": $0], merge: false)
        }
    }

    func restore(entity: BackupEntity) {
        if case .failure(let e) = entity.restoreVaridate() {
            self.actionCreator.backupError(error: e)
        }

        self.questListQuery.getDocuments {[weak self] result, e in
            guard e == nil else {
                self?.actionCreator.backupError(error: BackupError.network)
                return
            }

            let decorder = JSONDecoder()
            let quests = result?.documents
                .compactMap {
                    $0.data().values.first as? Data
                }
                .compactMap {
                    try? decorder.decode(Quest.self, from: $0)
                }

            guard let restoreQuests = quests, restoreQuests.isNotEmpty else {
                self?.actionCreator.backupUserStatus(status: BackupEntity.UserStatus.neverHosted )
                return
            }

            self?.actionCreator.backupUserStatus(status: BackupEntity.UserStatus.hosted)
            self?.actionCreator.restore(quests: restoreQuests)
        }
    }

}
