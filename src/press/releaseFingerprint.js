import {
  encodeAbiParameters,
  keccak256,
  stringToHex,
} from "viem";

export const COMMITMENT_SCHEME_VERSION = 1n;
export const CONFIG_SCHEMA_VERSION = 1n;
export const PUBLICATION_VERSION = 1n;

export const TEMPLATE_ID =
  keccak256(stringToHex("HELLBOX_PUBLICATION"));

export const RELEASE_CONFIG_DOMAIN =
  keccak256(
    stringToHex("HELLBOX_ABI_V1:RELEASE_CONFIG"),
  );

export const RELEASE_CONFIG_PARAMETER = {
  type: "tuple",
  components: [
    { name: "publicationKey", type: "string" },
    { name: "collectionName", type: "string" },
    { name: "collectionSymbol", type: "string" },
    { name: "maxSupply", type: "uint256" },
    { name: "primaryLifetimeCap", type: "uint256" },
    { name: "maxPerTransaction", type: "uint256" },
    {
      name: "immediateCreatorRecipient",
      type: "address",
    },
    {
      name: "immediateCreatorCount",
      type: "uint256",
    },
    { name: "tailRecipient", type: "address" },
    { name: "tailReserveCount", type: "uint256" },
    { name: "royaltyReceiver", type: "address" },
    { name: "royaltyBps", type: "uint96" },
    { name: "publisherAuthority", type: "address" },
    { name: "readerEnabled", type: "bool" },
    { name: "sealEnabled", type: "bool" },
    { name: "archiveCompatible", type: "bool" },
    {
      name: "dynamicMetadataEnabled",
      type: "bool",
    },
    {
      name: "erc6551Compatible",
      type: "bool",
    },
    { name: "rewardsCompatible", type: "bool" },
    {
      name: "hellforgeCompatible",
      type: "bool",
    },
    {
      name: "contextualTraitsEnabled",
      type: "bool",
    },
  ],
};

export const COMMITMENT_SET_PARAMETER = {
  type: "tuple",
  components: [
    {
      name: "publicationManifestDigest",
      type: "bytes32",
    },
    { name: "packageDigest", type: "bytes32" },
    {
      name: "fixedCopyRulesDigest",
      type: "bytes32",
    },
    { name: "birthTraitsDigest", type: "bytes32" },
    {
      name: "randomizationPolicyDigest",
      type: "bytes32",
    },
    {
      name: "rendererRulesDigest",
      type: "bytes32",
    },
    {
      name: "readerPolicyDigest",
      type: "bytes32",
    },
    {
      name: "pricingPoliciesDigest",
      type: "bytes32",
    },
    {
      name: "paymentRoutesDigest",
      type: "bytes32",
    },
    { name: "mintPhasesDigest", type: "bytes32" },
    {
      name: "royaltyPolicyDigest",
      type: "bytes32",
    },
    {
      name: "treasuryPolicyDigest",
      type: "bytes32",
    },
    {
      name: "metadataPolicyDigest",
      type: "bytes32",
    },
    {
      name: "capabilityPolicyDigest",
      type: "bytes32",
    },
    {
      name: "protocolCompatibilityDigest",
      type: "bytes32",
    },
    {
      name: "closurePolicyDigest",
      type: "bytes32",
    },
    {
      name: "authorityPolicyDigest",
      type: "bytes32",
    },
    { name: "eventPolicyDigest", type: "bytes32" },
  ],
};

const RELEASE_DIGEST_PARAMETERS = [
  { type: "bytes32" },
  { type: "uint256" },
  { type: "uint256" },
  { type: "uint256" },
  { type: "bytes32" },
  { type: "uint256" },
  { type: "address" },
  RELEASE_CONFIG_PARAMETER,
  COMMITMENT_SET_PARAMETER,
];

function asUint(value) {
  return typeof value === "bigint"
    ? value
    : BigInt(value);
}

function canonicalReleaseConfig(config) {
  return {
    ...config,
    maxSupply: asUint(config.maxSupply),
    primaryLifetimeCap:
      asUint(config.primaryLifetimeCap),
    maxPerTransaction:
      asUint(config.maxPerTransaction),
    immediateCreatorCount:
      asUint(config.immediateCreatorCount),
    tailReserveCount:
      asUint(config.tailReserveCount),
    royaltyBps: asUint(config.royaltyBps),
  };
}

/**
 * Computes the aggregate digest of the 18 separately versioned
 * publication commitments.
 *
 * This is the JavaScript equivalent of:
 * keccak256(abi.encode(commitments))
 */
export function computeCommitmentsDigest(
  commitments,
) {
  const encoded = encodeAbiParameters(
    [COMMITMENT_SET_PARAMETER],
    [commitments],
  );

  return keccak256(encoded);
}

/**
 * Computes the frozen Hellbox publication release fingerprint.
 *
 * IMPORTANT:
 * - Uses ABI encoding, never packed encoding.
 * - chainId must be the real target chain.
 * - factoryAddress must be the actual factory that will deploy
 *   the publication.
 * - This function does not normalize or silently rewrite text.
 *   Press validation must supply already-canonical values.
 *
 * This is the JavaScript equivalent of the V1 Solidity formula:
 *
 * keccak256(
 *   abi.encode(
 *     RELEASE_CONFIG_DOMAIN,
 *     COMMITMENT_SCHEME_VERSION,
 *     CONFIG_SCHEMA_VERSION,
 *     PUBLICATION_VERSION,
 *     TEMPLATE_ID,
 *     chainId,
 *     factoryAddress,
 *     config,
 *     commitments
 *   )
 * )
 */
export function computeReleaseConfigDigest({
  chainId,
  factoryAddress,
  config,
  commitments,
}) {
  const encoded = encodeAbiParameters(
    RELEASE_DIGEST_PARAMETERS,
    [
      RELEASE_CONFIG_DOMAIN,
      COMMITMENT_SCHEME_VERSION,
      CONFIG_SCHEMA_VERSION,
      PUBLICATION_VERSION,
      TEMPLATE_ID,
      asUint(chainId),
      factoryAddress,
      canonicalReleaseConfig(config),
      commitments,
    ],
  );

  return keccak256(encoded);
}
