#[test_only]
module rui::rui_tests;

use rui::board;
use rui::semaphore;

#[test]
fun test_verify_proof() {
    use std::string;
    use sui::test_scenario;

    let verifying_key = x"3be0d71d3abd18a49e02d4a521d97ae3525f51354e5c0c4cc319a1c3b510be086de81b565368ba4e912ac5e5d2c704904cebdf8be6396b164c47172ddcf3932a3b07cc2381513b01393c4d7b98453ac0ab4da725e6208bffcd5feecd8dfe3a9a6d0854cc83f563a5f6014b3fb77d249566fcf18edbb0cdb2a80e8b6922307b2c63b1e48eb88098196090f6fa718df3daf5c055995cff181407e4d3b1e3b5af1560ca264801a37e4d5ce9b3db9d1df5c6cb46ecf4ce31f31ea4c5ad5bc30f2b1f0ec1452b30cee37ffe43ca5ca5034725a7646afdfa31ca1394797eea6ca634b0020000000000000032f8184e881cfb83fe68bdce5d49b1c30e17acc363e1d273a200a9656599968e3be7eecd8ce4ecab66a77e8305d2e18953f3d3871cb73f48caf4094fb6f2df86";
    let proof_points = x"a3dd600e71fa679c907281d34290922725441d27c852e99ab8ac6fd8cd6e41823295e193f9dd0a6e6814e8e83a43e11ba6286475a43a0c114b48f12c3a379b1e62a5b4342bc7ec316dfa4382358df2a20787c15fe6c60368432ad5c72bf9731ad7a99ee0b0575263c41b2de87c45eeca3c1bcebfd027fc0e92ba1b2d510be60d";
    let public_inputs = x"97bc431329e00c7c28eddebd32fc99850a97673b75e5b3fd272e8a3adebf1c0b";

    assert!(semaphore::verify_proof(verifying_key, proof_points, public_inputs));

    let mut scenario = test_scenario::begin(@0xA);
    let ctx = test_scenario::ctx(&mut scenario);

    let mut qa = board::test_create_qa(string::utf8(b"123"), ctx);
    board::add_answer(
        verifying_key,
        proof_points,
        public_inputs,
    &mut qa,
        b"123",
        ctx
    );
    qa.test_delete_qa();

    test_scenario::end(scenario);
}
