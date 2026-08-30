import {
  keccak256,
  stringToHex,
} from "viem";

import {
  COMMITMENT_SCHEME_VERSION,
  CONFIG_SCHEMA_VERSION,
  PUBLICATION_VERSION,
  TEMPLATE_ID,
  RELEASE_CONFIG_DOMAIN,
  computeCommitmentsDigest,
  computeReleaseConfigDigest,
} from "../../src/press/releaseFingerprint.js";

const CHAIN_ID = 943n;

const FACTORY =
  "0x5555555555555555555555555555555555555555";

const config = {
  publicationKey: "hellbox-native-001",
  collectionName: "Hellbox Native Issue #1",
  collectionSymbol: "HELL001",

  maxSupply: 216n,
  primaryLifetimeCap: 6n,
  maxPerTransaction: 1n,

  immediateCreatorRecipient:
    "0x1111111111111111111111111111111111111111",
  immediateCreatorCount: 6n,

  tailRecipient:
    "0x2222222222222222222222222222222222222222",
  tailReserveCount: 3n,

  royaltyReceiver:
    "0x3333333333333333333333333333333333333333",
  royaltyBps: 369n,

  publisherAuthority:
    "0x4444444444444444444444444444444444444444",

  readerEnabled: true,
  sealEnabled: true,
  archiveCompatible: true,
  dynamicMetadataEnabled: true,
  erc6551Compatible: true,
  rewardsCompatible: true,
  hellforgeCompatible: true,
  contextualTraitsEnabled: true,
};

const commitments = {
  publicationManifestDigest:
    keccak256(stringToHex("publication-manifest-v1")),
  packageDigest:
    keccak256(stringToHex("package-v1")),
  fixedCopyRulesDigest:
    keccak256(stringToHex("fixed-copy-rules-v1")),
  birthTraitsDigest:
    keccak256(stringToHex("birth-traits-v1")),
  randomizationPolicyDigest:
    keccak256(stringToHex("randomization-policy-v1")),
  rendererRulesDigest:
    keccak256(stringToHex("renderer-rules-v1")),
  readerPolicyDigest:
    keccak256(stringToHex("reader-policy-v1")),
  pricingPoliciesDigest:
    keccak256(stringToHex("pricing-policies-v1")),
  paymentRoutesDigest:
    keccak256(stringToHex("payment-routes-v1")),
  mintPhasesDigest:
    keccak256(stringToHex("mint-phases-v1")),
  royaltyPolicyDigest:
    keccak256(stringToHex("royalty-policy-v1")),
  treasuryPolicyDigest:
    keccak256(stringToHex("treasury-policy-v1")),
  metadataPolicyDigest:
    keccak256(stringToHex("metadata-policy-v1")),
  capabilityPolicyDigest:
    keccak256(stringToHex("capability-policy-v1")),
  protocolCompatibilityDigest:
    keccak256(stringToHex("protocol-compatibility-v1")),
  closurePolicyDigest:
    keccak256(stringToHex("closure-policy-v1")),
  authorityPolicyDigest:
    keccak256(stringToHex("authority-policy-v1")),
  eventPolicyDigest:
    keccak256(stringToHex("event-policy-v1")),
};

const commitmentsDigest =
  computeCommitmentsDigest(commitments);

const releaseConfigDigest =
  computeReleaseConfigDigest({
    chainId: CHAIN_ID,
    factoryAddress: FACTORY,
    config,
    commitments,
  });

console.log(
  JSON.stringify(
    {
      vector: "HELLBOX_ABI_V1_NATIVE_216_GOLDEN_001",
      commitmentSchemeVersion:
        COMMITMENT_SCHEME_VERSION.toString(),
      configSchemaVersion:
        CONFIG_SCHEMA_VERSION.toString(),
      publicationVersion:
        PUBLICATION_VERSION.toString(),
      chainId: CHAIN_ID.toString(),
      factory: FACTORY,
      templateId: TEMPLATE_ID,
      releaseConfigDomain: RELEASE_CONFIG_DOMAIN,
      commitmentsDigest,
      releaseConfigDigest,
    },
    null,
    2,
  ),
);
