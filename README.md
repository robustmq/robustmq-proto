# Robust-Proto

The protobuf protocol for RobustMQ grpc server.

- broker_mqtt
- journal_server
- placement_center

## Install

```bash
cargo add robustmq-proto-build --git=https://github.com/robustmq/robustmq-proto.git
```

**Import proto file directly**

If you want to generate your own protobuf protocol, you can add this repo as submodule in your project.

```bash
git submodule add https://github.com/robustmq/robustmq-proto.git ./robustmq-proto
```

## Usage

### Rust

Install crate from git as first. And add the following code into your `build.rs`

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    robustmq_proto_build::setup()?;
    Ok(())
}
```