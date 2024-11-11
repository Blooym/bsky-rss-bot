mod bsky;
mod commands;
mod database;
mod rss;

use anyhow::Result;
use clap::Parser;
use commands::{CommandRoot, ExecutableCommand};
use dotenvy::dotenv;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() -> Result<()> {
    dotenv().ok();
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or(EnvFilter::new("info")))
        .init();

    CommandRoot::parse().run().await
}
