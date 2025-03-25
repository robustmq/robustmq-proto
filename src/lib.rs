pub fn setup() -> Result<(), Box<dyn std::error::Error>> {
    let proto_root = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));

    // Declare dependencies for all proto files and directories
    println!("cargo:rerun-if-changed={}", proto_root.join("protos/journal_server/*.proto").display());
    println!("cargo:rerun-if-changed={}", proto_root.join("protos/broker_mqtt/*.proto").display());
    println!("cargo:rerun-if-changed={}", proto_root.join("protos/placement_center/*.proto").display());
    println!("cargo:rerun-if-changed={}", proto_root.join("protos/prost_validation_types/*.proto").display());

    // Journal Engine
    tonic_build::configure().build_server(true).compile_protos(
        &[
            proto_root.join("protos/journal_server/proto/admin.proto").to_str().unwrap(),
            proto_root.join("protos/journal_server/proto/engine.proto").to_str().unwrap(),
            proto_root.join("protos/journal_server/proto/inner.proto").to_str().unwrap(),
            proto_root.join("protos/journal_server/proto/record.proto").to_str().unwrap(),
        ],
        &[proto_root.join("protos/journal_server/proto/").to_str().unwrap()],
    )?;

    // MQTT Broker
    tonic_build::configure().build_server(true).compile_protos(
        &[
            proto_root.join("protos/broker_mqtt/proto/admin.proto").to_str().unwrap(),
            proto_root.join("protos/broker_mqtt/proto/inner.proto").to_str().unwrap(),
        ],
        &[proto_root.join("protos/broker_mqtt/proto/").to_str().unwrap()],
    )?;

    // Placement Center
    let config = {
        let mut c = prost_build::Config::new();
        c.type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize)]");
        c.service_generator(tonic_build::configure().service_generator());
        c
    };
    prost_validate_build::Builder::new().compile_protos_with_config(
        config,
        &[
            proto_root.join("protos/placement_center/proto/journal.proto").to_str().unwrap(),
            proto_root.join("protos/placement_center/proto/kv.proto").to_str().unwrap(),
            proto_root.join("protos/placement_center/proto/mqtt.proto").to_str().unwrap(),
            proto_root.join("protos/placement_center/proto/inner.proto").to_str().unwrap(),
            proto_root.join("protos/placement_center/proto/openraft.proto").to_str().unwrap(),
        ],
        &[
            proto_root.join("protos/placement_center/proto/").to_str().unwrap(),
            proto_root.join("protos/prost_validation_types/proto/").to_str().unwrap(),
        ],
    )?;
    Ok(())
}
