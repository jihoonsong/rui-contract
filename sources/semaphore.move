module rui::semaphore {
    use sui::package;
    use sui::tx_context::sender;
    use sui::event;
    use sui::groth16;

    public struct SEMAPHORE has drop {}

    public struct Member has store {
        identity_commitment: vector<u8>,
    }

    public struct Group has key, store {
        id: UID,
        members: vector<Member>,
    }
    
    public struct CreateGroupEvent has copy, drop {
        id: ID,
    }
    
    public struct AddMemberEvent has copy, drop {
        id: ID,
        identity_commitment: vector<u8>,
    }

    public struct RemoveMemberEvent has copy, drop {
        id: ID,
        identity_commitment: vector<u8>,
    }

    fun init(witness: SEMAPHORE, ctx: &mut TxContext) {
        let publisher = package::claim(witness, ctx);
        transfer::public_transfer(publisher, sender(ctx));
    }

    entry fun create_group(ctx: &mut TxContext) {
        let group = Group {
            id: object::new(ctx),
            members: vector::empty(),
        };

        event::emit(CreateGroupEvent {
            id: object::uid_to_inner(&group.id),
        });
        
        transfer::transfer(group, sender(ctx));
    }

    entry fun add_member(group: &mut Group, identity_commitment: vector<u8>, _ctx: &mut TxContext) {
        vector::push_back<Member>(&mut group.members, Member {
            identity_commitment,
        });
        
        event::emit(AddMemberEvent {
            id: object::uid_to_inner(&group.id),
            identity_commitment,
        });
    }

    entry fun remove_member(group: &mut Group, identity_commitment: vector<u8>, _ctx: &mut TxContext) {
        let mut i = 0;
        while (i < group.members.length()) {
            if (group.members[i].identity_commitment == identity_commitment) {
                let Member { identity_commitment: _ } = group.members.remove(i);

                event::emit(RemoveMemberEvent {
                    id: object::uid_to_inner(&group.id),
                    identity_commitment,
                });

                break
            };

            i = i + 1;
        };
    }

    entry fun verify_proof(verifying_key: vector<u8>, proof_points: vector<u8>, public_inputs: vector<u8>): bool {
        let prepared_verifying_key = groth16::prepare_verifying_key(&groth16::bn254(), &verifying_key);
        let proof_points = groth16::proof_points_from_bytes(proof_points);
        let public_proof_inputs = groth16::public_proof_inputs_from_bytes(public_inputs);

        groth16::verify_groth16_proof(&groth16::bn254(), &prepared_verifying_key, &public_proof_inputs, &proof_points)
    }
}
